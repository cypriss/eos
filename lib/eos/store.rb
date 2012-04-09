class Store
  attr_accessor :agent
  attr_accessor :store_id
  
  def initialize(agent, store_id)
    self.agent = agent
    self.store_id = store_id
  end
  
  def page
    @page ||= self.agent.get("/eos/stores-sell.php?fsid=#{self.store_id.to_i}&_=#{Time.now.to_i}")
  end
  
  def body
    @body ||= page.body
  end
  
  def name
    page.search('div:nth(2)').text.scan(/[^(]+/).first.strip
  end
  
  def product_ids
    @product_ids ||= body.scan(/sc_pid=(\d+)/).flatten.uniq.map(&:to_i)
  end
  
  def store_products
    @store_products ||= self.product_ids.map {|pid| StoreProduct.new(self.agent, self.store_id, pid) }
  end
  
  def store_products_like(name)
    store_products.select {|sp| sp.name =~ /#{name}/ }
  end
  
  def autosell!
    store_products.each do |sp|
      sp.autosell!
    end
  end
  
  def import_uri
    page.links.select {|p| p.uri.to_s =~ /market-import-store\.php/ }.first.uri
  end
  
  def importer
    @importer ||= Importer.new(self.agent, import_uri)
  end
end
