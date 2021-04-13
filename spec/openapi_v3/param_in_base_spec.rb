# frozen_string_literal: true

require 'spec_helper'

describe 'setting of param type, such as `query`, `path`, `formData`, `body`, `header`' do
  before :all do
    module TheApi
      class ParamTypeApi < Grape::API
        desc 'full set of request param types using `:in`'
        namespace :defined_in do
          params do
            optional :in_query, type: String, documentation: { in: 'query' }
            optional :in_header, type: String, documentation: { in: 'header' }
          end
          get do
            { 'declared_params' => declared(params) }
          end

          params do
            requires :in_path, type: Integer
            optional :in_query, type: String, documentation: { in: 'query' }
            optional :in_header, type: String, documentation: { in: 'header' }
          end
          get ':in_path' do
            { 'declared_params' => declared(params) }
          end

          params do
            optional :in_path, type: Integer
            optional :in_query, type: String, documentation: { in: 'query' }
            optional :in_header, type: String, documentation: { in: 'header' }
          end
          delete ':in_path' do
            { 'declared_params' => declared(params) }
          end
        end

        desc 'full set of request param types using `:param_type`'
        namespace :defined_param_type do
          params do
            optional :in_query, type: String, documentation: { param_type: 'query' }
            optional :in_header, type: String, documentation: { param_type: 'header' }
          end
          get do
            { 'declared_params' => declared(params) }
          end
        end

        add_swagger_documentation
      end
    end
  end

  def app
    TheApi::ParamTypeApi
  end

  describe 'defined param in using `:param_type`' do
    subject do
      get '/swagger_doc/defined_param_type'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/defined_param_type']['get']['parameters']).to eql(
        [
          { 'in' => 'query', 'name' => 'in_query', 'required' => false, 'schema' => { 'type' => 'string' } },
          { 'in' => 'header', 'name' => 'in_header', 'required' => false, 'schema' => { 'type' => 'string' } }
        ]
      )
    end
  end

  describe 'defined param in' do
    subject do
      get '/swagger_doc/defined_in'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/defined_in']['get']['parameters']).to eql(
        [
          { 'in' => 'query', 'name' => 'in_query', 'required' => false, 'schema' => { 'type' => 'string' } },
          { 'in' => 'header', 'name' => 'in_header', 'required' => false, 'schema' => { 'type' => 'string' } }
        ]
      )
    end

    specify do
      expect(subject['paths']['/defined_in/{in_path}']['get']['parameters']).to eql(
        [
          { 'in' => 'path', 'name' => 'in_path', 'required' => true, 'schema' => { 'type' => 'integer', 'format' => 'int32' } },
          { 'in' => 'query', 'name' => 'in_query', 'required' => false, 'schema' => { 'type' => 'string' } },
          { 'in' => 'header', 'name' => 'in_header', 'required' => false, 'schema' => { 'type' => 'string' } }
        ]
      )
    end

    specify do
      expect(subject['paths']['/defined_in/{in_path}']['delete']['parameters']).to eql(
        [
          { 'in' => 'path', 'name' => 'in_path', 'required' => true, 'schema' => { 'type' => 'integer', 'format' => 'int32' } },
          { 'in' => 'query', 'name' => 'in_query', 'required' => false, 'schema' => { 'type' => 'string' } },
          { 'in' => 'header', 'name' => 'in_header', 'required' => false, 'schema' => { 'type' => 'string' } }
        ]
      )
    end
  end
end
