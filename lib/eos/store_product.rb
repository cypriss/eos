class StoreProduct
  attr_accessor :agent
  attr_accessor :store_id
  attr_accessor :product_id
  
  def initialize(agent, store_id, product_id)
    self.agent = agent
    self.store_id = store_id
    self.product_id = product_id
  end
  
  def page
    # http://www.ratjoy.com/eos/stores-sell-set-price.php?fsid=2013&sc_pid=238&_=1333922931180
    @page ||= self.agent.get("/eos/stores-sell-set-price.php?fsid=#{self.store_id}&sc_pid=#{self.product_id}&_=#{Time.now.to_i}")
  end
  
  def quality
    page.search(".sspi_details:nth(3)").text.strip.to_i
  end
  
  def quantity
    page.search(".sspi_details:nth(4)").text.strip.to_f
  end
  
  def cost
    page.search(".sspi_details:nth(5)").text.strip.gsub(/\$/, '').to_f
  end
  
  def name
    page.links.first.text
  end
  
  def has_inventory?
    (page.body =~ /Product not found in warehouse/).nil?
  end
  
  def avg_price
    html = page.body
    
    match = html.match /Average selling price \(World\).+?(\d+(\.\d+)?)/
    (match && match[1].to_f) || 0
  end
  
  def autosell!
    return unless has_inventory?
    c = [2.0 * cost, avg_price].max
    if c > 0
      sell!(c)
    end
  end
  
  def sell!(price)
    input = page.search('input').select {|i| i.attr('onblur').to_s =~ /updateSprice/ }.first
    ident = input.attr('onblur').scan(/\d+/).first.to_i
    
    cents = (price * 100).to_i
    puts "Selling #{name} for #{price} (cost=#{cost}, avg_price=#{avg_price})"
    resp = self.agent.get("/eos/stores-sell-set-price-start.php?sales_price=#{cents}&ipid_wh_id=#{ident}")
    puts "status = #{resp.body}"
  end
  
end