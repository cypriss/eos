class Importer
  attr_accessor :agent
  attr_accessor :uri
  
  # In the form [{:name => "Apple", :price => 123.23, :quality => 33, :buyable_id => 929, :product_id => 332}]
  attr_accessor :products
  
  def initialize(agent, uri)
    self.agent = agent
    self.uri = uri
  end
  
  def page
    @page ||= self.agent.get(self.uri)
  end
  
  def pages
    @pages ||= begin
      uris = page.links.map {|l| l.uri.to_s }.select {|l| l =~ /page=\d+/  }.uniq
      @pages = uris.map {|u| self.agent.get(u) } << page
    end
  end
  
  def products
    @products ||= begin
      @products = []
      pages.each do |cur_page|
        trs = cur_page.search('table.default_table tr')
        trs.each do |tr|
          
          inner_html = tr.inner_html
          if inner_html =~ /pid=\d+/
            prod = {}
            
            prod[:name] = tr.search('td:nth(3)').text
            prod[:quality] = tr.search('td:nth(4)').text.to_i
            prod[:price] = tr.search('td:nth(5)').text.gsub(/\$/, '').to_f
            prod[:buyable_id] = inner_html.scan(/buyFromMarket\((\d+),/).flatten.uniq.map(&:to_i).first
            prod[:product_id] = inner_html.scan(/pid=(\d+)/).flatten.uniq.map(&:to_i).first
            
            @products << prod
          end
        end
      end
      @products
    end
  end
  
  def buy_each(quantity)
    products.group_by {|prod| prod[:name] }.each_pair do |name, prods|
      cheapest = prods.min {|a, b| a[:price] <=> b[:price] }
      
      puts "Buying #{quantity} of #{cheapest[:name]}"
      resp = agent.get("/eos/market-import-buy.php?market_prod_id=#{cheapest[:buyable_id]}&buy_num=#{quantity}")
      puts "Status = #{resp.code}"
    end
  end
end