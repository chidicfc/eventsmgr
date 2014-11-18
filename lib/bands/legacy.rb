require "pry"

class LegacyData < Antenna::Band

  def tunnable?
    transmission.tags.include? "legacy_data"
  end

  def tune
    transmission.event_types.each do |template|
      # StoreEventTemplate.new template

      d = template.duration.split(' ')

      if d[0].to_i < 10
        d[0] = "0%s" % d[0]
      end

      case d[1]
      when "hours"
        template.duration = "#{d[0]}:00"
      when "seconds"
        template.duration = "00:00"
      when "mins"
        template.duration = "00:#{d[0]}"
      when "minutes"
        template.duration = "00:#{d[0]}"
      end

      dataset = DB[:event_templates]
      if dataset.where(:title => template.title).all == []
        template.id = UUID.new.generate
        dataset.insert(:id => template.id, :title => template.title, :duration => template.duration, :description => template.description, :status => "active")

        unless template.coaches_fees == []
          template.coaches_fees.each do |coaches_fee|
            dataset = DB[:coach_fees]
            coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.id)
          end
        end



        unless template.events == []
          template.events.each do |event|
            dataset = DB[:events]
            event.id = UUID.new.generate
            dataset.insert(:id => event.id, :title => event.subtitle, :duration => template.duration, :event_template_id => template.id, :date => Date.parse(event.start_time).strftime("%d/%m/%Y"), :start_time => event.start_time.split(" ")[1], :timezone => event.timezone, :cohort => event.cohort_name)

            unless event.coaches == []
              event.coaches.each do |coach|
                dataset=DB[:assigned_coaches]
                dataset.insert(:event_id => event.id, :name => coach.name, :email => coach.email, :image => coach.image)
              end
            end

            unless template.coaches_fees == []
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
  end
end

class StoreEventTemplate

  def initialize template
    execute template
  end

  def execute template
    # d = template.duration.split(' ')
    # case d[1]
    # when "hours"
    #   template.duration = "#{d[0]}:0"
    # when "seconds"
    #   template.duration = "0:0"
    # else
    #   template.duration = "0:#{d[0]}"
    # end
    #
    # dataset = DB[:event_templates]
    # if dataset.where(:title => template.title).all == []
    #   dataset.insert(:id => template.id, :title => template.title, :duration => template.duration, :description => template.description, :status => "active")
    #
    #   unless template.coaches_fees == []
    #     template.coaches_fees.each do |coaches_fee|
    #       dataset = DB[:coach_fees]
    #       coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.id)
    #     end
    #   end
    #
    #
    #
    #   unless template.events == []
    #     template.events.each do |event|
    #       dataset = DB[:events]
    #       dataset.insert(:id => event.id, :title => event.subtitle, :duration => template.duration, :event_template_id => template.id, :date => Date.parse(event.start_time).strftime("%d/%m/%Y"), :start_time => event.start_time.split(" ")[1], :timezone => event.timezone, :cohort => event.cohort_name)
    #
    #       unless event.coaches == []
    #         event.coaches.each do |coach|
    #           dataset=DB[:assigned_coaches]
    #           dataset.insert(:event_id => event.id, :name => coach.name, :email => coach.email, :image => coach.image)
    #         end
    #       end
    #
    #       unless template.coaches_fees == []
    #         template.coaches_fees.each do |coaches_fee|
    #           dataset = DB[:coach_fees]
    #           coach_fee = dataset.insert(:currency => coaches_fee.currency, :amount => coaches_fee.amount, :event_template_id => template.id, :event_id => event.id)
    #         end
    #       end
    #
    #     end # end template.events.each
    #   end # unless template.events
    # end # end if

  end
end
