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
          dataset.insert(:id => template.uuid, :title => template.title, :duration => template.duration, :description => template.description, :status => "active")

          unless template.coaches_fees.empty?
            template.coaches_fees.each do |coaches_fee|
              dataset = DB[:coach_fees]
              coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.uuid)
            end
          end



          unless template.events.empty?
            template.events.each do |event|
              dataset = DB[:events]
              dataset.insert(:id => event.uuid,:income_amount => event.income_amount,:income_currency => event.income_currency,:title => event.subtitle,:duration => event.duration,:description => event.details,:event_template_id => template.uuid,:date => Date.parse(event.start_time).strftime("%d/%m/%Y"),:start_time => event.start_time.split(" ")[1],:timezone => ActiveSupport::TimeZone.new("#{event.timezone}").to_s,:cohort => event.cohort_name,:cohort_id => event.cohort_id)

              unless event.coaches.empty?
                event.coaches.each do |coach|
                  dataset=DB[:assigned_coaches]
                  dataset.insert(:event_id => event.uuid, :name => coach.name, :email => coach.email, :image => coach.image)
                end
              end

              unless event.coaches_fees.empty?
                event.coaches_fees.each do |coaches_fee|
                  dataset = DB[:coach_fees]
                  coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.uuid, :event_id => event.uuid)
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
