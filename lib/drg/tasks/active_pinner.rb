module DRG
  module Tasks
    class ActivePinner
      include Log

      attr_reader :gemfile, :type
      attr_writer :versions

      # @param [Symbol] type of pin to perform. Available options are [:available, :minor, :patch]
      def initialize(type = :patch)
        @type = type
        @gemfile = Gemfile.new
        @versions = {}
      end

      def perform(gem_name = nil)
        updated_gems = []
        if gem_name
          updated_gems << update(gem_name)
        else
          Updater.new.perform do |gems|
            load_versions gems
            gems.each do |gem|
              updated_gems << update(gem)
            end
          end
        end
        updated_gems.compact!
        log %Q(Done)
        log %Q(You may want to run: "bundle update #{updated_gems.join ' '}") if updated_gems.any?
        gemfile.write if gemfile.saved_lines.any?
      end

      # @note calls #latest_minor_version and #latest_patch_version
      # @returns [nil|String]
      def update(gem_name)
        spec = ::Bundler.locked_gems.specs.find { |spec| spec.name == gem_name }
        gem = spec && gemfile.find_by_name(spec.name)
        return nil unless gem
        latest_version = public_send("latest_#{type}_version", spec.name, spec.version)
        if latest_version
          log %Q(Updating "#{spec.name}" from #{spec.version.to_s} to #{latest_version})
          gemfile.update gem, latest_version
          spec.name
        else
          log %Q(No newer #{type} versions found for "#{spec.name}"), :grey
        end
      end

      #
      # Private
      #

      def latest_available_version(name, current_version)
        new_versions(name, current_version).first
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def latest_minor_version(name, current_version)
        new_versions(name, current_version).select { |version|
          segments = version.scan(/\d+/)
          major = segments[0].to_i
          minor = segments[1].to_i
          minor > current_version.segments[1] && major == current_version.segments[0]
        }.first
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def latest_patch_version(name, current_version)
        new_versions(name, current_version).select { |version|
          segments = version.scan(/\d+/)
          major = segments[0].to_i
          minor = segments[1].to_i
          patch = segments[-1].to_i
          patch > current_version.segments[-1] && minor == current_version.segments[1] && major == current_version.segments[0]
        }.first
      end

      # @param [String] name of the gem
      # @param [String] current_version of the gem
      def new_versions(name, current_version)
        versions(name).select { |version| higher?(version.scan(/\d+/), current_version.segments) }
      end

      # @param [String] name of the gem
      # @return [Array] a list of available versions (e.g. ['1.2.0', '1.1.0'])
      def versions(name)
        @versions[name] ||= begin
          log %Q(Searching for latest #{type} version of "#{name}" ...)
          `gem query -radn ^#{name}$`.scan(/([\d.]+),/).flatten.uniq
        end
      end

      def load_versions(gems)
        load_gem_versions(gems).scan(/^(#{Array(gems).join('|')})\s\(([\d.\s,\w\-]+)\)$/).each do |gem_name, versions|
          @versions[gem_name] = versions.to_s.split(', ').map { |x| x[/([\d.\w\-]+)/, 1] }.compact
        end
      end

      def load_gem_versions(gems)
        log %Q(Searching for latest #{type} version of #{gems.join(', ')} ...)
        `gem query -ra #{gems.join(' ')}`
      end

      # @param [Array] list of a gem version's segments
      # @param [Array] other_list of another gem version's segments
      def higher?(list, other_list)
        higher = false
        equal = false
        sem_ver_size = [list.size, other_list.size].max
        sem_ver_size.times do |i|
          if list[i].to_i >= other_list[i].to_i
            higher = true
            equal = list[i].to_i == other_list[i].to_i
          else
            break
          end
        end
        higher && !equal
      end
    end
  end
end
