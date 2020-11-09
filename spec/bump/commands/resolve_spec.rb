require "spec_helper"

describe Bump::CLI::Commands::Resolve do
  it "resolves and writes to the destination file" do
    definition = spy(:definition)
    allow(Bump::CLI::Definition).to receive(:new).and_return(definition)

    expect do
      new_command.call(
        file: "/origin/file.yml",
        destination: "/destination/file.yml")
    end.to output(/External references have been resolved in \/destination\/file.yml/).to_stdout

    expect(definition).to have_received(:prepare)
    expect(definition).to have_received(:write).with(to: "/destination/file.yml")
  end

  it "allows overwriting a file if --overwrite is used" do
    definition = spy(:definition)
    allow(Bump::CLI::Definition).to receive(:new).and_return(definition)
    allow(File).to receive(:exists?).and_return(true)

    expect do
      new_command.call(
        file: "/origin/file.yml",
        overwrite: true)
    end.to output(/External references have been resolved in \/origin\/file.yml/).to_stdout
  end

  it "exits with an error if file exists" do
    definition = spy(:definition)
    allow(Bump::CLI::Definition).to receive(:new).and_return(definition)
    allow(File).to receive(:exists?).and_return(true)

    expect do
      begin
        new_command.call(
          file: "/origin/file.yml",
          overwrite: false)
      rescue SystemExit; end
    end.to output(/Destination \/origin\/file.yml already exists. Use --overwrite to overwrite it./).to_stderr
  end

  private

  def new_command
    command = Bump::CLI::Commands::Resolve.new
    allow(command).to receive(:exit)
    command
  end
end
