# frozen_string_literal: true

require 'spec_helper'

describe 'response' do
  before :all do
    module ResponseWithCrossReference
      class TheEntity < Grape::Entity
        expose :one, using: TheEntity
      end

      class TheApi < Grape::API
        desc 'This returns something',
             entity: TheEntity
        get '/entity_response' do
          { 'declared_params' => declared(params) }
        end

        add_swagger_documentation
      end
    end
  end

  def app
    ResponseWithCrossReference::TheApi
  end

  describe 'uses entity as response object' do
    subject do
      get '/swagger_doc/entity_response'
      JSON.parse(last_response.body)
    end

    specify do
      expect { subject }.not_to raise_error
    end
  end
end
