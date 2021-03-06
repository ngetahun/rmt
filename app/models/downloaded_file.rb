class DownloadedFile < ApplicationRecord
  class << self
    def track_file(checksum_type:, checksum:, local_path:, size:)
      find_or_initialize_by(local_path: local_path).tap do |record|
        record.checksum_type = checksum_type
        record.checksum = checksum
        record.file_size = size

        record.save if record.changed?
      end
    end
  end

  alias_attribute :size, :file_size
end
