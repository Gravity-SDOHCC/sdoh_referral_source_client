module UtilsHelper
  #### Compression/decompression helpers ####

  def compress_object(obj)
    return if obj.nil?

    begin
      serialized_obj = Marshal.dump(obj)
      compressed_obj = Base64.encode64(Zlib::Deflate.deflate(serialized_obj))
    rescue => e
      Rails.logger.error { "Error compressing object: #{e.message}" }
      nil
    end
  end

  def decompress_object(obj)
    return if obj.nil?

    begin
      decompressed_obj = Zlib::Inflate.inflate(Base64.decode64(obj))
      deserialized_obj = Marshal.load(decompressed_obj)
    rescue => e
      Rails.logger.error { "Error decompressing object: #{e.message}" }
      nil
    end
  end



end
