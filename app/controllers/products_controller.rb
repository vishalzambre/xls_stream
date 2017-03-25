require 'axlsx'

class ProductsController < ApplicationController
  def index
    respond_to do |format|
      format.html
      format.xlsx {render_xlsx}
    end
  end

  def render_xlsx
    set_file_headers
    set_streaming_headers
    response.status = 200
    # setting the body to an enumerator, rails will iterate this enumerator
    self.response_body = xlsx_lines
  end

  def set_file_headers
    file_name = 'products.xlsx'
    headers['Content-Type'] = 'application/vnd.openxmlformates-officedocument.spreadsheetml.sheet'
    headers['Content-disposition'] = "attachment; filename=\"#{file_name}\""
  end

  def set_streaming_headers
    # nginx doc: Setting this to "no" will allow unbuffered responses suitable
    # for Comet and HTTP streaming applications
    headers['X-Accel-Buffering'] = 'no'

    headers['Cache-Control'] ||= 'no-cache'
    headers.delete('Content-Length')
  end

  def xlsx_lines
    Enumerator.new do |y|
      p = Axlsx::Package.new
      wb = p.workbook
      ws = wb.add_worksheet(name: 'Products')
      ws.add_row(Product.xlsx_header)
      # ideally you'd validate the params, skipping here for brevity
      Product.find_in_batches(params, 5000) do |transaction|
        ws.add_row(transaction.to_xls_row)
      end
      y << p.to_stream.read.bytes.to_a.pack("C*")
    end
  end
end
