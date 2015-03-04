module Locomotive
  module Steam
    module Adapters
      module Filesystem
        module YAMLLoaders

          class ContentEntry

            include Adapters::Filesystem::YAMLLoader

            def load(scope)
              super
              load_list
            end

            private

            def load_list
              [].tap do |list|
                each(content_type_slug) do |label, attributes, position|
                  _attributes = { _position: position, _label: label.to_s }.merge(attributes)

                  setup_belongs_to_associations(_attributes)

                  list << _attributes
                end
              end
            end

            def setup_belongs_to_associations(attributes)
              content_type.belongs_to_fields.each do |field|
                # <name>_id
                attributes[:"#{field.name}_id"] = attributes.delete(field.name.to_sym)

                # _position_in_<name>
                attributes[:"_position_in_#{field.name}"] = attributes[:_position]
              end
            end

            def each(slug, &block)
              position = 0
              _load(File.join(path, "#{slug}.yml")).each do |element|
                label, attributes = element.keys.first, element.values.first
                yield(label, attributes, position)
                position += 1
              end
            end

            def path
              File.join(site_path, 'data')
            end

            def content_type
              @scope.context[:content_type]
            end

            def content_type_slug
              content_type.slug
            end

          end

        end
      end
    end
  end
end