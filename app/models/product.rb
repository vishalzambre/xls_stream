# product model
require 'csv'
class Product < ActiveRecord::Base
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values
      end
    end
  end

  def self.xlsx_header
    # Using ruby's built-in CSV::Row class
    # true - means its a header
    %w(name Price)
  end

  def to_xls_row
    [name, price]
  end

  def self.find_in_batches(filters, batch_size, &block)
    # find_each will batch the results instead of getting all in one go
    order('name').find_each(batch_size: batch_size) do |transaction|
      yield transaction
    end
  end
end
