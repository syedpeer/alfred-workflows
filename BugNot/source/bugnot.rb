#!/usr/bin/env ruby

require 'json'
require 'nokogiri'
require 'open-uri'

query = ARGV[0]
abort 'You need to specify a website' if query.nil?

script_filter_items = []

begin
  page = Nokogiri::HTML(open('http://bugmenot.com/view/' + query))
rescue OpenURI::HTTPError
  script_filter_items.push(title: "No logins availale for “#{query}”", valid: 'no')
else
  login_total = page.css('article.account').count

  (0..(login_total - 1)).each do |account|
    login_section = page.css('article.account')[account]
    username = login_section.css('kbd')[0].text
    password = login_section.css('kbd')[1].text
    success = login_section.css('li.success_rate').attr('class').text.gsub(/\D*/, '')

    script_filter_items.push(title: username.encode(xml: :text), subtitle: password.encode(xml: :text), icon: { path: "icons/#{success}.png" }, arg: "#{username}⸗#{password}")
  end
end

puts({ items: script_filter_items }.to_json)
