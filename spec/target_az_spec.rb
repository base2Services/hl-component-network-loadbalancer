require 'yaml'

describe 'compiled component network-loadbalancer' do
  
  context 'cftest' do
    it 'compiles test' do
      expect(system("cfhighlander cftest #{@validate} --tests tests/target_az.test.yaml")).to be_truthy
    end      
  end
  
  let(:template) { YAML.load_file("#{File.dirname(__FILE__)}/../out/tests/target_az/network-loadbalancer.compiled.yaml") }
  
  context "Resource" do

    
    context "NetworkLoadBalancer" do
      let(:resource) { template["Resources"]["NetworkLoadBalancer"] }

      it "is of type AWS::ElasticLoadBalancingV2::LoadBalancer" do
          expect(resource["Type"]).to eq("AWS::ElasticLoadBalancingV2::LoadBalancer")
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("network")
      end
      
      it "to have property SubnetMappings" do
          expect(resource["Properties"]["SubnetMappings"]).to eq({"Fn::If"=>["StaticIPs", [{"SubnetId"=>{"Fn::Select"=>[0, {"Ref"=>"SubnetIds"}]}, "AllocationId"=>{"Ref"=>"Nlb0EIPAllocationId"}}, {"SubnetId"=>{"Fn::Select"=>[1, {"Ref"=>"SubnetIds"}]}, "AllocationId"=>{"Ref"=>"Nlb1EIPAllocationId"}}, {"SubnetId"=>{"Fn::Select"=>[2, {"Ref"=>"SubnetIds"}]}, "AllocationId"=>{"Ref"=>"Nlb2EIPAllocationId"}}, {"SubnetId"=>{"Fn::Select"=>[3, {"Ref"=>"SubnetIds"}]}, "AllocationId"=>{"Ref"=>"Nlb3EIPAllocationId"}}, {"SubnetId"=>{"Fn::Select"=>[4, {"Ref"=>"SubnetIds"}]}, "AllocationId"=>{"Ref"=>"Nlb4EIPAllocationId"}}], {"Ref"=>"AWS::NoValue"}]})
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
    
    context "mysqlTargetGroup" do
      let(:resource) { template["Resources"]["mysqlTargetGroup"] }

      it "is of type AWS::ElasticLoadBalancingV2::TargetGroup" do
          expect(resource["Type"]).to eq("AWS::ElasticLoadBalancingV2::TargetGroup")
      end
      
      it "to have property VpcId" do
          expect(resource["Properties"]["VpcId"]).to eq({"Ref"=>"VPCId"})
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq("TCP")
      end
      
      it "to have property Port" do
          expect(resource["Properties"]["Port"]).to eq(3306)
      end
      
      it "to have property TargetType" do
          expect(resource["Properties"]["TargetType"]).to eq("ip")
      end
      
      it "to have property Targets" do
          expect(resource["Properties"]["Targets"]).to eq([{"Id"=>"10.1.2.16/32", "Port"=>3306, "AvailabilityZone"=>"all"}])
      end
      
      it "to have property HealthCheckProtocol" do
          expect(resource["Properties"]["HealthCheckProtocol"]).to eq("TCP")
      end
      
      it "to have property Tags" do
          expect(resource["Properties"]["Tags"]).to eq([{"Key"=>"Environment", "Value"=>{"Ref"=>"EnvironmentName"}}, {"Key"=>"EnvironmentType", "Value"=>{"Ref"=>"EnvironmentType"}}])
      end
      
    end
    
    context "mysqlListener" do
      let(:resource) { template["Resources"]["mysqlListener"] }

      it "is of type AWS::ElasticLoadBalancingV2::Listener" do
          expect(resource["Type"]).to eq("AWS::ElasticLoadBalancingV2::Listener")
      end
      
      it "to have property Protocol" do
          expect(resource["Properties"]["Protocol"]).to eq("TCP")
      end
      
      it "to have property Port" do
          expect(resource["Properties"]["Port"]).to eq(3306)
      end
      
      it "to have property LoadBalancerArn" do
          expect(resource["Properties"]["LoadBalancerArn"]).to eq({"Ref"=>"NetworkLoadBalancer"})
      end
      
      it "to have property DefaultActions" do
          expect(resource["Properties"]["DefaultActions"]).to eq([{"TargetGroupArn"=>{"Ref"=>"mysqlTargetGroup"}, "Type"=>"forward"}])
      end
      
    end
    
    context "dbproxyLoadBalancerRecord" do
      let(:resource) { template["Resources"]["dbproxyLoadBalancerRecord"] }

      it "is of type AWS::Route53::RecordSet" do
          expect(resource["Type"]).to eq("AWS::Route53::RecordSet")
      end
      
      it "to have property HostedZoneName" do
          expect(resource["Properties"]["HostedZoneName"]).to eq({"Fn::Sub"=>"${EnvironmentName}.${DnsDomain}."})
      end
      
      it "to have property Name" do
          expect(resource["Properties"]["Name"]).to eq({"Fn::Sub"=>"dbproxy.${EnvironmentName}.${DnsDomain}."})
      end
      
      it "to have property Type" do
          expect(resource["Properties"]["Type"]).to eq("A")
      end
      
      it "to have property AliasTarget" do
          expect(resource["Properties"]["AliasTarget"]).to eq({"DNSName"=>{"Fn::GetAtt"=>["NetworkLoadBalancer", "DNSName"]}, "HostedZoneId"=>{"Fn::GetAtt"=>["NetworkLoadBalancer", "CanonicalHostedZoneID"]}})
      end
      
    end
    
  end

end