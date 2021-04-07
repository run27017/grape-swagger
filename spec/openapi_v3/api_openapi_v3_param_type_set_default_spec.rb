

require 'spec_helper'

describe 'setting of param type, such as `query`, `path`, `formData`, `body`, `header`' do
  include_context "#{MODEL_PARSER} swagger example"

  before :all do
    module TheApi
      class SettingDefaultBodyParamTypeApi < Grape::API
        namespace :wo_entities do
          desc 'post in body /wo entity'
          params do
            optional :in_query, type: Integer, documentation: { param_type: 'query' }
            optional :in_body_1, type: Integer, documentation: { desc: 'in_body_1' }
            optional :in_body_2, type: String, documentation: { desc: 'in_body_2' }
            optional :in_body_3, type: String, documentation: { desc: 'in_body_3' }
          end
          post '/in_body' do
            { 'declared_params' => declared(params) }
          end
        end

        add_swagger_documentation default_param_type: 'body'
      end
    end
  end

  def app
    TheApi::SettingDefaultBodyParamTypeApi
  end

  describe 'no entity given' do
    subject do
      get '/swagger_doc/wo_entities'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/wo_entities/in_body']['post']['parameters']).to eql(
        [
          { "format"=>"int32", "in"=>"query", "name"=>"in_query", "required"=>false, "type"=>"integer" },
          { 'name' => 'body', 'in' => 'body', 'required' => true, 'schema' => { '$ref' => '#/components/schemas/postWoEntitiesInBody' } }
        ]
      )
    end
  end
end
