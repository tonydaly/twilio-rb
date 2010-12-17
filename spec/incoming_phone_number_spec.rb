require 'spec_helper'

describe Twilio::IncomingPhoneNumber do

  let(:resource_uri) { "https://#{Twilio::ACCOUNT_SID}:#{Twilio::AUTH_TOKEN}@api.twilio.com/2010-04-01/Accounts/#{Twilio::ACCOUNT_SID}/IncomingPhoneNumbers" }
  before { Twilio::Config.setup { account_sid('AC000000000000'); auth_token('79ad98413d911947f0ba369d295ae7a3') } }

  def stub_api_call(response_file, uri_tail='')
    stub_request(:get, resource_uri + uri_tail + '.json').
      to_return :body => canned_response(response_file), :status => 200
  end

  describe '.all' do
    before { stub_api_call 'list_incoming_phone_numbers' }
    it 'returns a collection of objects with a length corresponding to the response' do
      resp = Twilio::IncomingPhoneNumber.all
      resp.length.should == 1
    end

    it 'returns a collection containing instances of Twilio::AvailablePhoneNumber' do
      resp = Twilio::IncomingPhoneNumber.all
      resp.all? { |r| r.is_a? Twilio::IncomingPhoneNumber }.should be_true
    end

    it 'returns a collection containing objects with attributes corresponding to the response' do
      numbers = JSON.parse(canned_response('list_incoming_phone_numbers').read)['incoming_phone_numbers']
      resp    = Twilio::IncomingPhoneNumber.all

      numbers.each_with_index do |obj,i|
        obj.each do |attr, value| 
          resp[i].send(attr).should == value
        end
      end
    end

    it 'accepts options to refine the search' do
      stub_request(:get, resource_uri + '.json?FriendlyName=example&PhoneNumber=2125550000').
        to_return :body => canned_response('list_incoming_phone_numbers'), :status => 200
      Twilio::IncomingPhoneNumber.all :phone_number => '2125550000', :friendly_name => 'example'
      a_request(:get, resource_uri + '.json?PhoneNumber=2125550000&FriendlyName=example').should have_been_made
    end
  end

  describe '.find' do
    context 'for a valid call' do
      before do
        stub_request(:get, resource_uri + '/PN2a0747eba6abf96b7e3c3ff0b4530f6e' + '.json').
          to_return :body => canned_response('incoming_phone_number'), :status => 200
      end

      it 'returns an instance of Twilio::IncomingPhoneNumber' do
        call = Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e'
        call.should be_a Twilio::IncomingPhoneNumber 
      end

      it 'returns an object with attributes that correspond to the API response' do
        response = JSON.parse(canned_response('incoming_phone_number').read)
        call     = Twilio::IncomingPhoneNumber.find 'PN2a0747eba6abf96b7e3c3ff0b4530f6e'
        response.each { |k,v| call.send(k).should == v }
      end
    end

    context 'for a string that does not correspond to a real call' do
      before do
        stub_request(:get, resource_uri + '/phony' + '.json').to_return :status => 404
      end
      it 'returns nil' do
        call = Twilio::IncomingPhoneNumber.find 'phony'
        call.should be_nil
      end
    end
  end

end