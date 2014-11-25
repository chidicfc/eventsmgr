require "pry"
require "active_support/all"

class LegacyData < Antenna::Band

  def tunnable?
    transmission.tags.include? "legacy_data"
  end

  def tune
    puts "processing legacy data"
    begin
    transmission.event_types.each do |template|
      # StoreEventTemplate.new template

      unless template.duration.nil? || template.duration.empty?
        d = template.duration.split(' ')
      else
        d = ["1", "hour"]
      end

      if (d[0].to_i < 10) && ((d[1].include? "hour") || (d[1].include? "min") || (d[1].include? "sec"))
        d[0] = "0%s" % d[0]
      end

      if (d[1].include? "hour") && d[2].nil?
        template.duration = "#{d[0]}:00"
      elsif (d[1].include? "sec") && d[2].nil?
        template.duration = "01:00"
      elsif (d[1].include? "min")
        template.duration = "00:#{d[0]}"
      elsif (d[1].include? "hour") && (d[3].include? "min")
        if d[2].to_i < 10
          d[2] = "0%s" % d[2]
        end
        template.duration = "#{d[0]}:#{d[2]}"
      elsif (d[1].include? "day") && d[2].nil?
        d[0] = "#{d[0].to_i * 8}"
        if d[0].to_i < 10
          d[0] = "0%s" % d[0]
        end
        template.duration = "#{d[0]}:00"
      end

      dataset = DB[:event_templates]
      if dataset.where(:title => template.title).all.empty?
        template.id = UUID.new.generate
        dataset.insert(:id => template.id, :title => template.title, :duration => template.duration, :description => template.description, :status => "active")

        unless template.coaches_fees.empty?
          template.coaches_fees.each do |coaches_fee|
            dataset = DB[:coach_fees]
            coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.id)
          end
        end



        unless template.events.empty?
          template.events.each do |event|
            dataset = DB[:events]
            event.id = UUID.new.generate
            dataset.insert(:id => event.id, :title => event.subtitle, :duration => template.duration, :event_template_id => template.id, :date => Date.parse(event.start_time).strftime("%d/%m/%Y"), :start_time => event.start_time.split(" ")[1], :timezone => ActiveSupport::TimeZone.find_tzinfo("#{event.timezone}").to_s, :cohort => event.cohort_name)

            unless event.coaches.empty?
              event.coaches.each do |coach|
                dataset=DB[:assigned_coaches]
                dataset.insert(:event_id => event.id, :name => coach.name, :email => coach.email, :image => coach.image)
              end
            end

            unless template.coaches_fees.empty?
              template.coaches_fees.each do |coaches_fee|
                dataset = DB[:coach_fees]
                coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.id, :event_id => event.id)
              end
            end

          end # end template.events.each
        end # unless template.events
      end # end if

    end #transmission.event_types

    puts "handled by #{self.class} band"
  rescue Exception => e
     puts e.message
      puts e.backtrace
    end
  end
end
