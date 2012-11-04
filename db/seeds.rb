# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

admin = EbyUser.create( :login => 'admin', :password => EbyUser.hashfunc('admin'), :role_typist => true, :role_proofer => true, :role_fixer => true, :max_proof_level => 3, :role_publisher => true, :role_partitioner => true)
