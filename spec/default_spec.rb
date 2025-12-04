require 'yaml'

describe 'compiled component network-loadbalancer' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/default.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/default/network-loadbalancer.compiled.yaml") }
  
  context "Resource" do

    
    context "NetworkLoadBalancer" do
      let(:resource) { template["Resources"]["NetworkLoadBalancer"] }

      it "is of type AWS::ElasticLoadBalancingV2::LoadBalancer" do
          expect(resource["Type"]).to eq("AWS::ElasticLoadBalancingV2::LoadBalancer")
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("network")
      end
      
      it "to have property Subnets" do
          expect(resource["Properties"]["Subnets"]).to eq({"Ref"=>"SubnetIds"})
      end
      
      it "to have property SecurityGroups" do
          expect(resource["Properties"]["SecurityGroups"]).to eq({"Fn::If"=>["AddSecurityGroups", {"Ref"=>"SecurityGroupIds"}, {"Ref"=>"AWS::NoValue"}]})
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
      it "to have property LoadBalancerAttributes" do
          expect(resource["Properties"]["LoadBalancerAttributes"]).to eq([{"Key"=>"deletion_protection.enabled", "Value"=>false}, {"Key"=>"load_balancing.cross_zone.enabled", "Value"=>false}])
      end
      
    end
    
  end

end