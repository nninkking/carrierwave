module CarrierWave
  module Uploader
    module Url
      extend ActiveSupport::Concern
      include CarrierWave::Uploader::Configuration
      include CarrierWave::Utilities::Uri

      ##
      # === Parameters
      #
      # [Hash] optional, the query params (only AWS)
      #
      # === Returns
      #
      # [String] the location where this file is accessible via a url
      #
      def url(options = {})
        if file.respond_to?(:url) and not (tmp_url = file.url).blank?
          if Aws::CF::Signer.is_configured?
            file.method(:url).arity == 0 ? Aws::CF::Signer.sign_url(tmp_url) : Aws::CF::Signer.sign_url(file.url(options))
          else
            file.method(:url).arity == 0 ? tmp_url : file.url(options)
          end
        elsif file.respond_to?(:path)
          path = encode_path(file.path.sub(File.expand_path(root), ''))

          if host = asset_host
            if host.respond_to? :call
              Aws::CF::Signer.is_configured? ? Aws::CF::Signer.sign_url("#{host.call(file)}#{path}") : "#{host.call(file)}#{path}"
            else
              Aws::CF::Signer.is_configured? ? Aws::CF::Signer.sign_url("#{host}#{path}") : "#{host}#{path}"
            end
          else
            Aws::CF::Signer.is_configured? ? Aws::CF::Signer.sign_url((base_path || "") + path) : (base_path || "") + path
          end
        end
      end

      def to_s
        url || ''
      end

    end # Url
  end # Uploader
end # CarrierWave
