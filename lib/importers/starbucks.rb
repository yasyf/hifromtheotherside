module Importers
  class Starbucks
    HEADERS = {
      store: 'Brand',
      number: 'eGift Number',
      url: 'URL',
      challenge: 'Challenge Code',
      amount: 'Denomination',
    }

    def initialize(filename)
      @filename = filename
    end

    def import!
      CSV.foreach(@filename, headers: true) do |row|
        GiftCard.create! HEADERS.map { |k,v| [k, row[v]] }.to_h
      end
    end
  end
end
