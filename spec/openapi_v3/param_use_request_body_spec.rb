# frozen_string_literal: true

require 'spec_helper'

describe 'setting of param type, such as `query`, `path`, `formData`, `body`, `header`' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class ParamUseRequestBodyApi < Grape::API
        namespace :wo_entities do
          desc 'put in body /wo entity'
          params do
            requires :key, type: Integer, documentation: { param_type: 'query' }
            optional :in_body_1, type: Integer, documentation: { desc: 'in_body_1', param_type: 'body' }
            optional :in_body_2, type: String, documentation: { desc: 'in_body_2', param_type: 'body' }
            optional :in_body_3, type: String, documentation: { desc: 'in_body_3', param_type: 'body' }
          end
          put '/in_body' do
            { 'declared_params' => declared(params) }
          end
        end

        add_swagger_documentation use_request_body: true
      end
    end
  end

  def app
    TheApi::ParamUseRequestBodyApi
  end

  describe 'use request body' do
    subject do
      get '/swagger_doc/wo_entities'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/wo_entities/in_body']['put']['parameters']).to eql(
        [
          { 'in' => 'query', 'name' => 'key', 'schema' => { 'type' => 'integer', 'format' => 'int32' }, 'required' => true }
        ]
      )
      expect(subject['paths']['/wo_entities/in_body']['put']['requestBody']).to eql(
        'content' => {
          'application/json' => {
            'schema' => { '$ref' => '#/components/schemas/putWoEntitiesInBody' }
          }
        }
      )
    end
  end
end
