pragma solidity ^0.5.1;
//pragma experimental ABIEncoderV2;

contract Seller{
    address payable owner;
    uint[] products;
    
    //struct for stor data
    struct ProductsDetails{
        
        address payable owner;
        address  productaddress;
        uint id;
        uint price;
        string desc;
        bool available;
    }
    
    
    mapping(address => bool) IsVerifiedSeller;
    mapping (uint => ProductsDetails) proOption;
    mapping (address => mapping(address => mapping(address => uint))) SellerDeposite;
    
    
     constructor() public payable{
        //set owner      
        owner=msg.sender;
     }
     
     //function called by owner to allow seller address.
     function AllowSeller(address _seller) public returns(bool successful){
         require(owner==msg.sender);
         
        IsVerifiedSeller[_seller]=true;
         return true;
     }
     
     
     //only allow seller address can set the product details.
     function setProduct(address payable _seller,address _prdadd, uint _productid,uint _price,string memory _des)public returns(bool){
        
        require(IsVerifiedSeller[_seller]==true);
        require(_seller==msg.sender);
        
        if(_productid==proOption[_productid].id){revert();}
        
        ProductsDetails memory prduct = ProductsDetails( _seller,_prdadd,_productid,_price,_des,true);
        proOption[_productid]=prduct;
        products.push(_productid);
        return true;
    } 
    
    
    //to get the details about the products
     function getProduct(uint _productid) public view returns(address _owner,address product,uint price,string memory _des,bool _available){

        return (proOption[_productid].owner,proOption[_productid].productaddress,proOption[_productid].price,proOption[_productid].desc,proOption[_productid].available);
        
    }
    
    //for check the balance of address.
     function balanceOf(address _address)public view returns(uint256 balance) {

        return (_address.balance)/(10**18);

    }
    
    
    //for check the insurance address of buyer address send money to seller address
    function sellerDeposite(address _seller,address _Insurance,address _Buyer)public view returns (uint _balance){
        return (SellerDeposite[_seller][_Insurance][_Buyer])/(10**18);
    }
    
    //you can get all the product id of products via call this method.
    function getallProductIds() public view returns (uint[] memory){
        return products;
    }
    
    
}




contract Insurance is Seller{
    
        address owner;
        address[] InsuranceAddresses;
    
        mapping(address => bool) public IsVerified;
        mapping(address => uint) intestrate;
        mapping(address => IMIaddress) ownAddress;
        mapping(address => mapping(uint => address)) FindInsurance;
        mapping(address => mapping( uint => mapping(address => uint))) InsuranceAndBuyer;
        mapping (address => mapping(address =>mapping(uint => uint))) Remining;
        mapping(address => mapping( address => mapping(uint => bool))) temp;
        mapping(address => mapping(address => mapping(uint => uint))) starttime;
        
        //struct that sore the own insurance address.
        struct IMIaddress{
            address payable InsuranceAddress;
        }

    //get the insurance rate of insurance address.
    //method can called by all user.
    function getInterestRate(address _insuraceAdd) public view returns(uint _intestrate){
      return intestrate[_insuraceAdd];
    }
    
    //this method can clled by owner of the contract
    //that method allow insurance address and set insurace rate
    function AllowInsuranceAddress(address payable _insuraceAdd,uint _intestrate) public returns(bool successful){
        
        require(msg.sender==owner); 
        require(IsVerified[_insuraceAdd]==false);
        require(_intestrate>0);
        
        IsVerified[_insuraceAdd]=true;
        IMIaddress memory imi = IMIaddress(_insuraceAdd);
        ownAddress[_insuraceAdd]=imi;
        intestrate[_insuraceAdd]=_intestrate;
        InsuranceAddresses.push(_insuraceAdd);
        return true;
        
    }
    

    //this method give total Product Price with insurance rate
    //this method tell user what actual price, user needs to pay
    function ProductPriceAfterEmi(uint _productId, address _insuraceAdd) public view returns (uint _price){
      require(IsVerified[_insuraceAdd]==true,"Insurance address not Verified");
      return (Seller.proOption[_productId].price+(((Seller.proOption[_productId].price)*(intestrate[_insuraceAdd]))/100));
    }

    //this method gives EMI price that user needs to pay per month. 
    function getEmiPrice (uint _productId, address _insuraceAdd)public view returns(uint _EMIprice){
         return ((ProductPriceAfterEmi(_productId,_insuraceAdd))/12);
    }
    
    //this method is only called by allow insurance address.
    //if buyer called BuyProduct()  then insurance address called this method.
    //insurance address enter Seller address in getProduct details method.
    //this method transfer total ether of price to seller.
    //aftr payment, buyer become owner of the product.
    //after this buyer can call the PayEMI to pay the emi to iInsurance address.
    function transfer(address ToSellerAddress,address payable Buyer,uint _productid) payable public{
          
           require(IsVerified[msg.sender]==true,"Insurance address not Verified");
           require(Seller.IsVerifiedSeller[ToSellerAddress]==true,"Invalid Seller");
           require(msg.value>=Seller.proOption[_productid].price,"price error");
           require(ToSellerAddress==Seller.proOption[_productid].owner,"owner can not buy it's own product");
           require(Seller.proOption[_productid].available==true,"item not available");
           require(temp[msg.sender][Buyer][_productid]==true,"product error");
        //   require(InsuranceAndBuyer[msg.sender][_productid][Buyer]>=getEmiPrice(_productid,msg.sender),"error 6");
          
        
        
        Seller.proOption[_productid].owner.transfer(msg.value);
        // Deposite[ToSellerAddress][FromInsuranceAddress] = Deposite[ToSellerAddress][FromInsuranceAddress] + msg.value;
        SellerDeposite[ToSellerAddress][msg.sender][Buyer] = SellerDeposite[ToSellerAddress][msg.sender][Buyer] + msg.value;
        Seller.proOption[_productid].owner=Buyer;
        Seller.proOption[_productid].available=false;
        FindInsurance[Buyer][_productid]=msg.sender;
        uint userprice = ProductPriceAfterEmi(_productid,msg.sender);
        starttime[msg.sender][Buyer][_productid]=now;
        Remining[Buyer][msg.sender][_productid] = ((userprice)*(10**18));
    }
    
    //to get all the insurance address.
    //buyer will call this function to view the insurance address.
    function getallInsuranceAddress() public view returns (address[] memory){
        return InsuranceAddresses;
    }
    
    //only insurance address that buyer requst for BuyProduct call call this method.
    //via this method insurance address will verify buyer want to buy product or not.
    function CheckforBuyer(address Buyer,uint _productId) public view returns (bool Success){
        return temp[msg.sender][Buyer][_productId];
    }
}

contract Buyer is Insurance{
    
    //any user can buy available Product.
    //buyer need to buy product id and insurance address.
    function BuyProduct(uint _productId, address _InsuranceAddress) public returns (bool Successess){
        
        uint userprice = ProductPriceAfterEmi(_productId,_InsuranceAddress);
        
        require((msg.sender).balance>=((userprice)*(10**18)),"4 error");
        require(IsVerified[_InsuranceAddress]==true,"3 error");
        require(Seller.proOption[_productId].available==true,"2 error");
        require(temp[_InsuranceAddress][msg.sender][_productId]==false);
        require(msg.sender!=Seller.proOption[_productId].owner,"owner can not buy it's own product");
        
       temp[_InsuranceAddress][msg.sender][_productId]=true;
        return true;
        
    }
    
    //buyer can pay emi if insurace address send paymet via transfer method.
    function PayEMI(uint _productId, address _InsuranceAddress)public payable returns (bool Successess){
      
       require(now >= starttime[_InsuranceAddress][msg.sender][_productId] + 1 minutes);
       require(IsVerified[_InsuranceAddress]==true,"3 error");
       require(proOption[_productId].owner==msg.sender);
       require(temp[_InsuranceAddress][msg.sender][_productId]==true);
       require(_InsuranceAddress==FindInsurance[msg.sender][_productId],"wrong InsuranceAddress");
        
        uint EMIprice = getEmiPrice(_productId,_InsuranceAddress);
        require(msg.value>=EMIprice);
        
        ownAddress[_InsuranceAddress].InsuranceAddress.transfer(msg.value);
       // Seller.Deposite[_InsuranceAddress][msg.sender] = Seller.Deposite[_InsuranceAddress][msg.sender] + msg.value;
        InsuranceAndBuyer[_InsuranceAddress][_productId][msg.sender] = InsuranceAndBuyer[_InsuranceAddress][_productId][msg.sender] + msg.value;
        Remining[msg.sender][_InsuranceAddress][_productId] = Remining[msg.sender][_InsuranceAddress][_productId] - (msg.value);
        starttime[_InsuranceAddress][msg.sender][_productId]=now;
        return true;
      
        }
  
      //Remining method can return Remining ether need to payed by Buyer
      //after transfer price amount of seller by insurance address.
      
      function ReminingEMI(address _Buyer,address payable _InsuranceAddress,uint _productId)public view returns (uint){
          return ((Remining[_Buyer][_InsuranceAddress][_productId])/(10**18));
      }
}