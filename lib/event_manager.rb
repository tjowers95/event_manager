require 'csv'
require 'google/apis/civicinfo_v2'
require 'erb'

def clean_zipcode(zipcode)
  zipcode.to_s.rjust(5,"0")
end

def legislators_by_zipcode(zip)
ci = Google::Apis::CivicinfoV2::CivicInfoService.new
ci.key = 'AIzaSyAocBP1UaZZirwaVkZMe_VCLPXT8Mzba1M'

 begin
  legislators = ci.representative_info_by_address(
                   address: zipcode,
                   levels: 'country'
                   roles: ['legislatorUpperBody','legislatorLowerBody'] ).officials
 rescue
  "You can find your representatives by visiting www.commoncause.org/take-action/find-elected-officials"
 end
end

def save_letters(id,form_letter)
  Dir.mkdir("output") unless Dir.exists?("output")

  filename = "output/thanks_#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

puts "EventManager Initialized!"


contents = CSV.open "event_attendees.csv", header_converters: :symbol 

template_letter = File.read "form_letter.erb"
erb_template = ERB.new template_letter

contents.each do |row|

  name = row[:first_name]

  zipcode = clean_zipcode(row[:zipcode]))

  legislators = legislators_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)

  save_letters(id,form_letter)
end
