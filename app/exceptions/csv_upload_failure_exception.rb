# frozen_string_literal: true

##
# Raises exception if at least one validation or upload a csv file failed for
# {CsvUploadService}[rdoc-ref:CsvUploadService].
#
class CsvUploadFailureException < ApplicationException
  ##
  # Initializer method for the class. Calls +super+ method on parent class (ApplicationException)
  #
  # ==== Attributes
  # * +msg+ - string - messaged passed to parent exception
  def initialize(msg = nil)
    super(msg)
  end
end
