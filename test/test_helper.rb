ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  class TestCase
    parallelize(workers: :number_of_processors)
    fixtures :all

    def file_fixture_attachable
      { io: file_fixture("sample.png").open, filename: "sample.png", content_type: "image/png" }
    end

    def create_ref(**attrs)
      Ref.create!(image: file_fixture_attachable, **attrs)
    end
  end
end
