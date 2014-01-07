require 'spec_helper'

describe WAMP::Server do
  let(:dummy_socket) { DummySocket.new }
  subject { WAMP::Server.new(host: "localhost", port: 9292) }

  context "initilization" do
    it "should accept a hash of options" do
      expect(subject.options).to eq({ host: "localhost", port: 9292, engine: { type: :memory } })
    end

    it "should have an empty hash of topics" do
      expect(subject.topics).to eq({})
    end
  end

  context "#start" do
    context 'when request is not a websocket request' do
      it 'should return Not Found' do
        expect(subject.start().call({}).shift).to eq(404)
      end
    end

    context 'when request is a websocket request' do
      let!(:ws) { Faye::WebSocket.new({}, ['wamp'], ping: 25) }
      
      before { Faye::WebSocket.stub(:new).and_return(ws) }
      before { Faye::WebSocket.stub(:websocket?).and_return(true) }

      it 'creates a new websocket' do
        expect(Faye::WebSocket).to receive(:new)

        subject.start().call({})
      end

      it 'returns async rack response' do
        expect(ws).to receive(:rack_response)

        subject.start().call({})
      end


      it 'assigns onopen event' do
        expect(ws).to receive(:onopen=)

        subject.start().call({})
      end

      it 'assigns onmessage event' do
        expect(ws).to receive(:onmessage=)

        subject.start().call({})
      end

      it 'assigns onclose event' do
        expect(ws).to receive(:onclose=)

        subject.start().call({})
      end
    end
  end

  context "bind" do
    it "should bind a subscribe callback do" do
      expect { subject.bind(:subscribe) { |client_id, topic| } }
        .to_not raise_error
    end

    it "should raise an error if an invalid binding name is given" do
      expect { subject.bind(:invalid) {} }
        .to raise_error "Invalid binding: invalid"
    end
  end
end
