$LOAD_PATH.unshift File.expand_path(File.dirname(__FILE__) + '/lib')

require 'eos'

eos = Eos.load
s = eos.stores.select {|z| z.name == "Sports Store" }.first
s.import_low(10000, 500, 50_000)

s = eos.stores.select {|z| z.name == "Hardware Store" }.first
s.import_low(10000, 500, 50_000) if s

s = eos.stores.select {|z| z.name == "Apparel Store" }.first
s.import_low(10000, 500, 50_000) if s

s = eos.stores.select {|z| z.name == "Electronics Store" }.first
s.import_low(10000, 500, 50_000) if s

