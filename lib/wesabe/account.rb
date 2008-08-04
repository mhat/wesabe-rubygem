class Wesabe::Account
  # The user-scoped account id, used to identify the account in URLs.
  attr_accessor :id
  # The user-provided account name ("Bank of America - Checking")
  attr_accessor :name
  # This account's balance or +nil+ if the account is a cash account.
  attr_accessor :balance
  # This account's currency.
  attr_accessor :currency
  # The financial institution this account is held at.
  attr_accessor :financial_institution
  
  # Initializes a +Wesabe::Account+ and yields itself.
  # 
  # @yieldparam [Wesabe::Account] account
  #   The newly-created account.
  def initialize
    yield self if block_given?
  end
  
  # Returns a +Wesabe::Account+ generated from Wesabe's API XML.
  # 
  # @param [REXML::Element] xml
  #   The <account> element from the API.
  # 
  # @return [Wesabe::Account]
  #   The newly-created account populated by +xml+.
  def self.from_xml(xml)
    new do |account|
      account.id = xml.elements["id"].text.to_i
      account.name = xml.elements["name"].text
      balance = xml.elements["current-balance"]
      account.balance = balance.text.to_f if balance
      account.currency = Wesabe::Currency.from_xml(xml.elements["currency"])
      fi = xml.elements["financial-institution"]
      account.financial_institution = Wesabe::FinancialInstitution.from_xml(fi) if fi
    end
  end
end