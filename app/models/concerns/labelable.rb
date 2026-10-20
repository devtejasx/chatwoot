module Labelable
  extend ActiveSupport::Concern

  included do
    acts_as_taggable_on :labels
    include Labelable::Persistence
  end

  def update_labels(labels = nil)
    update!(label_list: labels)
  end

  def add_labels(new_labels = nil)
    return if new_labels.blank?

    new_labels = Array(new_labels) # Make sure new_labels is an array
    combined_labels = labels + new_labels
    update!(label_list: combined_labels)
  end

  def remove_labels(labels_to_remove = nil)
    return if labels_to_remove.blank?

    removed = Array(labels_to_remove).map(&:downcase)
    update!(label_list: label_list.reject { |label| removed.include?(label.downcase) })
  end
end
