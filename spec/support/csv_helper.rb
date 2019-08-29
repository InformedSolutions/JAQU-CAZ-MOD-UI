# frozen_string_literal: true

module CsvHelper
  def csv_file(filename)
    File.join('spec', 'fixtures', 'files', 'csv', filename)
  end

  def empty_csv_file(filename)
    File.join('spec', 'fixtures', 'files', 'csv', 'empty', filename)
  end
end
