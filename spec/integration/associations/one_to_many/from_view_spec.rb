# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ROM::SQL::Associations::OneToMany, '#call' do
  include_context 'users'

  before do
    inferrable_relations.push(:puzzles)
  end

  subject(:assoc) do
    relations[:users].associations[:solved_puzzles]
  end

  with_adapters do
    before do
      conn.create_table(:puzzles) do
        primary_key :id
        foreign_key :user_id, :users, null: false
        column :text, String, null: false
        column :solved, TrueClass, null: false, default: false
      end

      conf.relation(:users) do
        schema(infer: true) do
          associations do
            has_many :puzzles
            has_many :puzzles, as: :solved_puzzles, view: :solved
          end
        end
      end

      conf.relation(:puzzles) do
        schema(infer: true)

        view(:solved, schema) do
          where(solved: true)
        end
      end

      relations[:puzzles].insert(user_id: joe_id, text: 'P1')
      relations[:puzzles].insert(user_id: joe_id, solved: true, text: 'P2')
    end

    it 'prepares joined relations using custom view' do
      relation = assoc.()

      expect(relation.schema.map(&:to_sql_name)).to eql([
        Sequel.qualify(:puzzles, :id),
        Sequel.qualify(:puzzles, :user_id),
        Sequel.qualify(:puzzles, :text),
        Sequel.qualify(:puzzles, :solved)
      ])

      expect(relation.count).to be(1)
      expect(relation.first).to eql(id: 2, user_id: 2, solved: db_true, text: 'P2')
    end
  end
end
