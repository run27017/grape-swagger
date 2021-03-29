# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class ResponseApiModelsFlatten < Grape::API
        format :json

        desc 'This returns something',
             success: [{ code: 200 }],
             failure: [
               { code: 400, message: 'NotFound', model: '' },
               { code: 404, message: 'BadRequest', model: Entities::ApiError }
             ]
        get '/use-response' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation(models: [Entities::UseResponse], models_flatten: true)
      end
    end
  end

  def app
    TheApi::ResponseApiModelsFlatten
  end

  describe 'uses entity as response object implicitly with route name' do
    subject do
      get '/swagger_doc/use-response'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/use-response']['get']).to eql(
        "summary"=>"This returns something",
        "produces"=>["application/json"],
        "responses"=> {
          "200"=>{"description"=>"This returns something", "schema"=>{"type"=>"object", "properties"=>{"mock_data"=>{"type"=>"string", "description"=>"it's a mock"}}}},
          "400"=>{"description"=>"NotFound"},
          "404"=>{"description"=>"BadRequest", "schema"=>{"type"=>"object", "properties"=>{"mock_data"=>{"type"=>"string", "description"=>"it's a mock"}}}}
        },
        "tags"=>["use-response"],
        "operationId"=>"getUseResponse"
      )
    end
  end
end
