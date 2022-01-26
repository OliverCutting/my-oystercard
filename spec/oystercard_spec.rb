require 'oystercard'

describe Oystercard do
  let(:entry_station){ double :station }
  let(:exit_station){ double :station }
  let(:journey){ {entry_station: entry_station, exit_station: exit_station}}

  it "can check the starting balance is 0" do
    expect(subject.balance).to eq(0)
  end 

  it "can top-up balance" do
    subject.balance
    expect(subject.top_up(5)).to eq(5)
  end 
  
  it "is initially not in a journey" do
    expect(subject).not_to be_in_journey
    # in_journey? use 'be_' and remove '?'' and for boolean methods
  end

  it "can issue error if balance is under minimum balance £1" do
    expect { subject.touch_in(entry_station) }.to raise_error "You do not have minimum balance of £1 to travel"
  end 

  it 'has and empty list of journeys by default' do
    expect(subject.journeys).to be_empty
  end

  context 'is already in_journey' do
    before do
      subject.instance_variable_set(:@entry_station, entry_station)
    end

    it "can touch out" do
      subject.touch_out(exit_station)
      expect(subject).not_to be_in_journey
    end

    it "can deduct fare from balance when you touch out" do      
      expect { subject.touch_out(exit_station) }.to change{subject.balance}.by (-Oystercard::MINIMUM_BALANCE)
      end 
  end

  

  context 'card has balance' do
    before do
      subject.instance_variable_set(:@balance, 90)
    end

    describe "#journey_log" do
      it 'stores the entry_station' do
       subject.touch_in(entry_station)
       subject.touch_out(exit_station)
       expect(subject.journeys[0][:entry_station]).to eq(entry_station)
      end

      it 'stores the exit_station' do
        subject.touch_in(entry_station)
        subject.touch_out(exit_station)
        expect(subject.journeys[0][:exit_station]).to eq(exit_station)
      end

      it 'has no journeys by default' do
        expect(subject.journeys).to be_empty
      end
    end

    it "can issue error if balance is over maximum limit" do
      maximum_balance = Oystercard::MAXIMUM_BALANCE
      expect { subject.top_up (1) }.to raise_error "Balance cannot exceed #{maximum_balance}"
    end 

    it "can touch in" do
      subject.touch_in(entry_station)
      expect(subject).to be_in_journey
    end

    it 'stores a journey' do
      subject.touch_in(entry_station)
      subject.touch_out(exit_station)
      expect(subject.journeys).to include journey
    end
  end
end 