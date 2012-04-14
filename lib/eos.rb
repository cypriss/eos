require 'mechanize'
require 'yaml'

require 'eos/store'
require 'eos/store_product'
require 'eos/importer'

class Eos
  attr_accessor :username, :password
  attr_accessor :agent
  
  def self.load
    yaml = YAML.load(File.read("credentials.yml"))
    eos = new(yaml["eos"]["username"], yaml["eos"]["password"])
    eos.login!
    eos
  end
  
  def initialize(username, password)
    self.username, self.password = username, password
    self.agent = Mechanize.new
  end
  
  def login!
    login = agent.post("http://www.ratjoy.com/login.php", {:username => "Jonathan", :password => "netbooks1", :nocache => rand})
    eos = agent.get("/eos/")
  end
  
  def store_ids
    return @store_ids if @store_ids
    
    stores = agent.get("/eos/stores.php")
    @store_ids = stores.body.scan(/fsid=(\d+)/).flatten.map(&:to_i)
  end
  
  def stores
    @stores ||= self.store_ids.map {|sid| Store.new(self.agent, sid) }
  end
    
end