# Encapsulates a txaction from Wesabe's API.
# <txaction>
#   <guid>0000000000000000000000000000000000000000000000000000000000000000</guid>
#   <date>2009-01-01</date>
#   <original-date>2009-01-01</original-date>
#   <amount type="float">-100.00</amount>
#   <merchant>
#     <id>123</id>
#     <name>Blue Bottle Cafe</name>
#   </merchant>
#   <raw-name>Blue Bottle Cafe on Mint</raw-name>
#   <raw-txntype>DEBIT</raw-txntype>
#   <tags type="array">
#     <tag>
#       <name>food</name>
#       <kind>merchant</kind>
#     </tag>
#     <tag>
#       <name>resturant</name>
#       <kind>merchant</kind>
#     </tag>
#     <tag>
#       <name>coffee</name>
#       <kind>merchant</kind>
#     </tag>
#   </tags>
# </txaction>

class Wesabe::Txaction < Wesabe::BaseModel
  attr_accessor :guid
  attr_accessor :date
  attr_accessor :original_date
  attr_accessor :amount
  attr_accessor :merchant_name
  attr_accessor :raw_name
  attr_accessor :tags
  attr_accessor :note
  
  
  # Initializes a +Wesabe::Txaction+ and yields itself.
  #
  # @yieldparam [Wesabe::Txaction] txaction
  #   The newly-created account.
  def initialize
    yield self if block_given?
  end
  
  def self.from_xml(xml)
    new do |txn|
      txn.guid          = xml.at('guid').inner_text
      txn.amount        = xml.at('amount').inner_text.to_f
      txn.note          = xml.at('note') ? xml.at('note').inner_text : ''
      txn.date          = Date.parse xml.at('date').inner_text
      txn.original_date = Date.parse xml.at('original-date').inner_text
      txn.merchant_name = (xml/ "merchant/name").inner_text
      txn.tags          = (xml/ "tags/tag/name").map{ |element| element.inner_text }
    end
  end
  
  def inspect
     inspect_these :guid, :date, :original_date, :amount, :merchant_name, :raw_name, :tags, :note
   end
end
