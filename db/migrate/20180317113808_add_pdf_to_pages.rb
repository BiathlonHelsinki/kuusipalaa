class AddPdfToPages < ActiveRecord::Migration[5.1]
  def change
    add_column :pages, :pdf, :string
    add_column :pages, :pdf_size, :integer, length: 8
    add_column :pages, :pdf_content_type, :string
  end
end
