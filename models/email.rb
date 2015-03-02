require 'erb'
require 'nokogiri'
require 'ostruct'
require 'redcarpet'
require 'pony'
require 'premailer'

require 'config/addon'
require 'config/sequel'
require 'models/account'

module Email
  def self.send(account_uuid, subject, markdown_body)
    account = Account.first(:uuid => account_uuid)
    content = replace_placeholders(markdown_body, account)
    subject.sub!(/\A\[ACTION REQUIRED\]/, "[ACTION REQUIRED on {{app_name}}]")
    subject = replace_placeholders(subject, account)
    mail(account.email_address, subject, content)
  end

  def self.test(subject, markdown_body)
    email = "team@#{ENV["DOMAIN"]}"
    mail(email, "[TEST] #{subject}", markdown_body)
    puts "Sent test to #{email}"
  end

  def self.mail(email, subject, markdown_body)
    options = default_smtp_options.merge({
      to: email,
      subject: subject,
      body: markdown_body,
      html_body: to_html(markdown_body)
    })
    Pony.mail(options)
  end

  def self.renderer
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      filter_html: true,
      no_styles: true,
      safe_links_only: true
    )
  end

  def self.html_template
    return @html_template if @html_template
    filename =  File.expand_path(File.dirname(__FILE__) + "/../views/email_layout.erb")
    erb_template = ""
    File.open(filename, "r") do |f|
      erb_template = f.read
    end
    namespace = OpenStruct.new(:addon_config => AddonConfig.settings)
    @html_template = ERB.new(erb_template).result(namespace.instance_eval { binding })
    @html_template
  end

  def self.replace_placeholders(content, account)
    placeholders = content.scan(/\{\{([^\}]+)\}\}/).flatten.uniq
    placeholders.each do |placeholder|
      value = account.send(placeholder.to_sym)
      content.gsub!("{{#{placeholder}}}", value)
    end
    content
  end

  def self.to_html(content)
    placeholder = "<!-- CONTENT-IN-HERE // -->"
    partial_content = renderer.render(content)
    html = html_template.sub(placeholder, partial_content)
    Premailer.new(html, with_html_string: true).to_inline_css
  end

  def self.default_smtp_options
    {
      from: "support@#{ENV["DOMAIN"]}",
      via: :smtp,
      via_options: {
        address: 'smtp.mandrillapp.com',
        port: '587',
        enable_starttls_auto: true,
        user_name: ENV['MANDRILL_USERNAME'],
        password: ENV['MANDRILL_APIKEY'],
        domain: ENV["DOMAIN"],
        authentication: 'login'
      }
    }
  end

end
