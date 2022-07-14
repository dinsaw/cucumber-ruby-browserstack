require 'selenium/webdriver'
require 'capybara/cucumber'
require 'browserstack/local'
require 'browserstack-automate'
BrowserStack.for "cucumber"

url = "http://#{ENV['BS_USERNAME']}:#{ENV['BS_AUTHKEY']}@hub.browserstack.com/wd/hub"

Capybara.register_driver :browserstack do |app|

  capabilities = Selenium::WebDriver::Remote::Capabilities.new
	if ENV['BS_AUTOMATE_OS']
		capabilities['os'] = ENV['BS_AUTOMATE_OS']
		capabilities['os_version'] = ENV['BS_AUTOMATE_OS_VERSION']
	else
		capabilities['platform'] = ENV['SELENIUM_PLATFORM'] || 'ANY'
	end

	capabilities['browser'] = ENV['SELENIUM_BROWSER'] || 'chrome'
	capabilities['browser_version'] = ENV['SELENIUM_VERSION'] if ENV['SELENIUM_VERSION']
	capabilities['browserstack.debug'] = 'true'
	capabilities['project'] = ENV['BS_AUTOMATE_PROJECT'] if ENV['BS_AUTOMATE_PROJECT']
	capabilities['build'] = ENV['BS_AUTOMATE_BUILD'] if ENV['BS_AUTOMATE_BUILD']      
  capabilities['browserstack.local'] = 'false'      

  if capabilities['browserstack.local'] && capabilities['browserstack.local'] == 'true';
    @bs_local = BrowserStack::Local.new
    bs_local_args = { "key" => "#{ENV['BS_AUTHKEY']}", "forcelocal" => true }
    @bs_local.start(bs_local_args)
  end
  Capybara::Selenium::Driver.new(app, :browser => :remote, :url => url, :desired_capabilities => capabilities)


end

Capybara.default_driver = :browserstack
Capybara.app_host = "http://www.google.com"
Capybara.run_server = false

at_exit do
  @bs_local.stop unless @bs_local.nil? 
end

require "allure-cucumber"

AllureCucumber.configure do |config|
  config.results_directory = "report/allure-results"
  config.clean_results_directory = true
  # config.logging_level = Logger::INFO
  # config.logger = Logger.new($stdout, Logger::DEBUG)
  # config.environment = "staging"

  # these are used for creating links to bugs or test cases where {} is replaced with keys of relevant items
  config.link_tms_pattern = "http://www.jira.com/browse/{}"
  config.link_issue_pattern = "http://www.jira.com/browse/{}"

  # additional metadata
  # environment.properties
  # config.environment_properties = {
  #   custom_attribute: "foo"
  # }
  # categories.json
  # config.categories = File.new("my_custom_categories.json")
end