module FidorApi

  class Collection
    include ActiveModel::Model
    include Enumerable

    attr_accessor :records
    attr_accessor :total_pages, :current_page, :limit_value, :total_entries, :meta

    def self.build(klass, response)
      new.tap do |object|
        data       = response["data"]
        collection = response["collection"]
        meta       = response["meta"] || response["meta_data"]

        object.records = data.map do |record|
          class_to_instantiate = if block_given?
            yield(record)
          else
            klass
          end

          class_to_instantiate.new(record)
        end

        if collection
          object.total_pages   = collection["total_pages"]
          object.current_page  = collection["current_page"]
          object.limit_value   = collection["per_page"]
          object.total_entries = collection["total_entries"]
        end
        object.meta = meta if meta
      end
    end

    def each(&block)
      records.each(&block)
    end

    # --- kaminari stuff -- maybe move somewhere else
    def last_page?
      current_page == total_pages
    end

    def next_page
      current_page + 1
    end
  end

end
