require "spec_helper"

describe FeatureGuard do
  let(:feature) { :some_feature_name }

  describe 'enabling and disabling a feature' do
    it 'turns the feature on and off in succession' do
      expect {
        FeatureGuard.enable feature
      }.to change {
        FeatureGuard.enabled? feature
      }.from(false).to(true)

      expect {
        FeatureGuard.disable feature
      }.to change {
        FeatureGuard.enabled? feature
      }.from(true).to(false)
    end
  end

  describe 'ramping a feature up and down' do
    let(:user_id) { 5435 }

    it 'allows a percentage of calls to use the feature' do
      expect {
        FeatureGuard.set_ramp feature, 100.0
      }.to change {
        FeatureGuard.allow? feature, user_id
      }.from(false).to(true)

      expect {
        FeatureGuard.set_ramp feature, 0.0
      }.to change {
        FeatureGuard.allow? feature, user_id
      }.from(true).to(false)
    end
  end

  describe '.enabled?' do
    subject { FeatureGuard.enabled? feature }

    context 'for a non-existent flag' do
      it { is_expected.to eq(false) }
    end

    context 'when the Redis client blows up or is non-existent' do
      before { FeatureGuard.stub(redis: nil) }

      it { is_expected.to eq(false) }
    end
  end

  describe '.all_flags' do
    it 'returns information on enabled flags' do
      expect {
        FeatureGuard.enable feature
      }.to change {
        FeatureGuard.all_flags
      }.from({}).to({feature.to_s => "1"})
    end
  end

  describe '.all_ramps' do
    it 'returns information on ramped flags' do
      expect {
        FeatureGuard.set_ramp feature, 50
      }.to change {
        FeatureGuard.all_ramps
      }.from({}).to({feature.to_s => "50.0"})
    end
  end
end
