module Concerns::Documentable
  extend ActiveSupport::Concern

  class_methods do
    def has_documents(*fields)
      fields.each do |field|
        after_initialize do
          @documents = {}
          @updated_documents = {}
        end

        define_method(field) do
          document_id = self.send("#{field.to_s}_id")

          @documents[field] ||= if document_id.present?
                                  Document.find_by(id: document_id)
                                else
                                  Document.new
                                end
        end

        define_method("#{field.to_s}=") do |document|
          self.send("#{field.to_s}_id=", document.id)
        end

        define_method("#{field.to_s}_file") do
          self.public_send(field).document
        end

        define_method("#{field}_file=") do |file|
          # NOTE: Check that this is actually an uploaded file
          # (eg. ActionDispatch::Http::UploadedFile) and not just an instance
          # of the Carrierwave uploader object being re-assigned.
          #
          if file.respond_to?(:tempfile)
            @updated_documents[field] = Document.new(
              documentable_type: self.class.name,
              documentable_id: self.id,
              kind: field,
              document: file,
            )
          end
        end

        before_save do
          @updated_documents.each {|key, doc|
            doc.save!
            self.send("#{key.to_s}_id=", doc.id)
          }
        end

        define_method("remove_#{field}") do
          false
        end

        define_method("remove_#{field}=") do |value|
          self.send("#{field.to_s}_id=", nil) unless (value.blank? || value == '0')
        end
      end
    end
  end

  included do
    private_class_method :has_documents
  end

end
