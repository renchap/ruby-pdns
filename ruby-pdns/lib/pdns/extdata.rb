require 'yaml'
require 'find'

module Pdns
    class Extdata
        def initialize
            loaddata

            Pdns.extdata = self
        end

        # Loads all data files in data dir, first it zeros the Hash containing all data
        # then goes through all files and load them, this ensures we have no unintended 
        # stale data at any time
        #
        # We should figure out some kind of flocking here so that updating and loading 
        # doesnt clash
        def loaddata
            datadir = Pdns.config.datadir
            @data = Hash.new

            raise "Cannot process external data, #{datadir} does not exist" unless File.directory?(datadir)
            Pdns.debug("Looking for external data in #{datadir}")

            dir = Dir.new(datadir) 

            dir.entries.grep(/\.pdb$/).each do |r|
                Pdns.debug("Loading data from #{datadir}/#{r}")
                
                pdbname = File.basename(r, ".pdb")

                begin
                    @data[pdbname] = Hash.new
                    @data[pdbname][:loadtime] = Time.now.to_i
                    @data[pdbname][:data] = YAML.load_file("#{datadir}/#{r}")

                    raise("Coult not find any data in file") unless @data[pdbname][:data]
                rescue Exception => e
                    Pdns.error("Could not load #{datadir}/#{r}: #{e}")
                    @data.delete pdbname if @data.include?(pdbname)
                end
            end
        end

        # Returns the entire data record for a certain record
        def all_data(record)
            @data.include?(record) ? @data[record] : {}
        end

        # Returns a specific key from a record else default
        def data(record, key, default=nil)
            return default unless @data.include?(record)

            @data[record][:data].include?(key) ? @data[record][:data][key] : default
        end

        # Means of updating the data kept on disk, this should be called from
        # a REST API or something.
        #
        # We should figure out some kind of flocking here so that updating and loading 
        # doesnt clash
        def update(record, key, val)
            datadir = Pdns.config.datadir

            Pdns.debug("Updating data for #{record}/#{key} = #{val} in #{datadir}")

            raise "Cannot process external data, #{datadir} does not exist" unless File.directory?(datadir)

            @data[record] = {:data => {}}  unless @data.include? record

            @data[record][:data][key] = val
            @data[record][:data][:updated] = Time.now.to_i

            File.open("#{datadir}/#{record}.pdb", "w") do |f|
                f.write(YAML.dump(@data[record][:data]))
            end
        end
    end
end

# vi:tabstop=4:expandtab:ai
