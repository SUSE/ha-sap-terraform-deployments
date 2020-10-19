# frozen_string_literal: true

class CreateSources < ActiveRecord::Migration[5.1]
  def change
    create_table :sources do |t|
      t.string :filename
      t.text :content

      t.timestamps
    end
    add_index :sources, :filename
  end
end
