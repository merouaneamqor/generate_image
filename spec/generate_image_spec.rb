RSpec.describe GenerateImage do
  let(:api_key) { 'test_api_key' }

  before do
    ENV['OPENAI_API_KEY'] = api_key
  end

  it "has a version number" do
    expect(GenerateImage::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'returns a configuration object' do
      config = GenerateImage.configure
      expect(config).to be_a(GenerateImage::Configuration)
    end

    it 'yields configuration to block' do
      GenerateImage.configure do |config|
        expect(config).to be_a(GenerateImage::Configuration)
      end
    end
  end

  describe '.generate_image' do
    let(:mock_provider) do
      double('provider').tap do |provider|
        allow(provider).to receive(:generate_image).and_return({ image_url: 'test_url' })
      end
    end

    before do
      allow_any_instance_of(GenerateImage::Configuration).to receive(:get_provider).and_return(mock_provider)
    end

    it 'provides a convenience method' do
      result = GenerateImage.generate_image('test prompt')
      expect(result).to have_key(:image_url)
    end

    it 'passes provider option to configuration' do
      config = double('config')
      allow(config).to receive(:get_provider).with(:stability_ai).and_return(mock_provider)

      allow(GenerateImage).to receive(:configuration).and_return(config)

      GenerateImage.generate_image('test prompt', provider: :stability_ai)
      expect(config).to have_received(:get_provider).with(:stability_ai)
    end
  end

  describe GenerateImage::Configuration do
    let(:config) { GenerateImage::Configuration.new }

    describe '#register_provider' do
      it 'registers a provider' do
        provider_class = double('provider_class')
        config.register_provider(:test, provider_class, 'api_key')

        expect(config.providers[:test]).to be_a(provider_class)
      end
    end

    describe '#get_provider' do
      it 'returns the default provider' do
        provider = config.get_provider
        expect(provider).to be_a(GenerateImage::OpenAIProvider)
      end

      it 'returns a specific provider' do
        provider = config.get_provider(:openai)
        expect(provider).to be_a(GenerateImage::OpenAIProvider)
      end

      it 'raises error for unknown provider' do
        expect { config.get_provider(:unknown) }.to raise_error(ArgumentError)
      end
    end

    describe '#set_default_provider' do
      it 'sets the default provider' do
        config.set_default_provider(:openai)
        expect(config.default_provider).to eq(:openai)
      end

      it 'raises error for unknown provider' do
        expect { config.set_default_provider(:unknown) }.to raise_error(ArgumentError)
      end
    end
  end

  describe GenerateImage::Client do
    describe '#initialize' do
      it 'initializes with default provider' do
        client = GenerateImage::Client.new
        expect(client.provider).to be_a(GenerateImage::OpenAIProvider)
      end

      it 'initializes with specific provider' do
        client = GenerateImage::Client.new(:openai)
        expect(client.provider).to be_a(GenerateImage::OpenAIProvider)
      end

      it 'raises error for unknown provider' do
        expect { GenerateImage::Client.new(:unknown) }.to raise_error(ArgumentError)
      end
    end

    describe '#generate_image' do
      let(:mock_provider) do
        double('provider').tap do |provider|
          allow(provider).to receive(:generate_image).and_return({ image_url: 'test_url' })
        end
      end

      let(:client) do
        client = GenerateImage::Client.new
        allow(client).to receive(:provider).and_return(mock_provider)
        client
      end

      it 'delegates to provider' do
        result = client.generate_image('test prompt')
        expect(mock_provider).to have_received(:generate_image).with('test prompt', {})
        expect(result).to have_key(:image_url)
      end
    end

    describe 'provider information methods' do
      let(:mock_provider) do
        double('provider').tap do |provider|
          allow(provider).to receive(:available_models).and_return(['model1', 'model2'])
          allow(provider).to receive(:supported_sizes).and_return(['256x256', '512x512'])
          allow(provider).to receive(:name).and_return('test_provider')
        end
      end

      let(:client) do
        client = GenerateImage::Client.new
        allow(client).to receive(:provider).and_return(mock_provider)
        client
      end

      it 'returns available models' do
        expect(client.available_models).to eq(['model1', 'model2'])
      end

      it 'returns supported sizes' do
        expect(client.supported_sizes).to eq(['256x256', '512x512'])
      end

      it 'returns provider name' do
        expect(client.provider_name).to eq('test_provider')
      end
    end
  end

  describe GenerateImage::Provider do
    let(:provider) { GenerateImage::Provider.new('test_key') }

    describe '#initialize' do
      it 'sets api_key' do
        expect(provider.api_key).to eq('test_key')
      end

      it 'sets name based on class' do
        expect(provider.name).to eq('provider')
      end
    end

    describe '#configured?' do
      it 'returns true when api_key is set' do
        expect(provider.configured?).to be true
      end

      it 'returns false when api_key is nil' do
        provider_nil = GenerateImage::Provider.new(nil)
        expect(provider_nil.configured?).to be false
      end

      it 'returns false when api_key is empty' do
        provider_empty = GenerateImage::Provider.new('')
        expect(provider_empty.configured?).to be false
      end
    end

    describe '#generate_image' do
      it 'raises NotImplementedError' do
        expect { provider.generate_image('test') }.to raise_error(NotImplementedError)
      end
    end
  end

  describe GenerateImage::OpenAIProvider do
    let(:provider) { GenerateImage::OpenAIProvider.new(api_key) }

    describe '#available_models' do
      it 'returns OpenAI models' do
        expect(provider.available_models).to include('dall-e-2', 'dall-e-3')
      end
    end

    describe '#supported_sizes' do
      it 'returns size mappings' do
        sizes = provider.supported_sizes
        expect(sizes).to be_a(Hash)
        expect(sizes['dall-e-2']).to include('512x512')
      end
    end
  end

  describe GenerateImage::StabilityAIProvider do
    let(:provider) { GenerateImage::StabilityAIProvider.new(api_key) }

    describe '#available_models' do
      it 'returns Stability AI models' do
        expect(provider.available_models).to include('stable-diffusion-v1-5')
      end
    end

    describe '#supported_sizes' do
      it 'returns supported sizes' do
        expect(provider.supported_sizes).to include('512x512')
      end
    end
  end
end
