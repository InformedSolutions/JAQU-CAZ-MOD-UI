# frozen_string_literal: true

class CsvUploadFailureException < ApplicationException
  def initialize(msg = nil)
    super(msg)
  end
end
