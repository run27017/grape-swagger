# frozen_string_literal: true

require 'spec_helper'

describe 'Param example' do
  def app
    Class.new(Grape::API) do
      format :json

      params do
        requires :id, type: Integer, documentation: { example: 123 }
        optional :name, type: String, documentation: { example: 'Person' }
        optional :obj, type: 'Object', documentation: { example: { 'foo' => 'bar' } }
      end

      get '/endpoint_with_examples' do
        { 'declared_params' => declared(params) }
      end

      add_swagger_documentation
    end
  end

  describe 'documentation with parameter examples' do
    subject do
      get '/swagger_doc/endpoint_with_examples'
      JSON.parse(last_response.body)
    end

    specify do
      expect(subject['paths']['/endpoint_with_examples']['get']['parameters']).to eql(
        [{ 'in' => 'query',
           'name' => 'id',
           'required' => true,
           'example' => 123,
           'schema' => { 'type' => 'integer', 'format' => 'int32' } },
         { 'in' => 'query',
           'name' => 'name',
           'required' => false,
           'example' => 'Person',
           'schema' => { 'type' => 'string' } },
         { 'in' => 'query',
           'name' => 'obj',
           'required' => false,
           'example' => { 'foo' => 'bar' },
           'schema' => { 'type' => 'Object' } }]
      )
    end
  end
end
