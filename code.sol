pragma solidity ^0.4.25;
contract Land {
    //owned becomes 1 when land is owned otherwise it is 0 by default
    struct cropSowDetail {
        uint isValid;
        string status;
        string croptype;
        uint256 time;
    }
    
    struct insuranceDetail {
        uint isValid;        
        string number;
        uint256 time;
    }

    struct claimDetail{
        uint isValid;
        string status;
        uint256 time;
    }
    
    mapping(uint8=>address) LandOwnerMapping;
    mapping(uint8=>mapping(address=>cropSowDetail)) landOwnerCropMapping;
    mapping(uint8=>mapping(address=> mapping(string => insuranceDetail))) landOwnerCropInsuranceMapping;
    mapping(uint8=>mapping(address=> mapping(string => claimDetail))) landOwnerInsuranceClaimMapping;

    function initialBuy(uint8 landId, address newOwner) public {
        LandOwnerMapping[landId] = newOwner;        
    }

    function checkLandOwner(uint8 landId, address owner) public view returns (string) {
        // checking land is owned by the owner
        if(LandOwnerMapping[landId] != owner){
            return "not a owner!!";
        }

        return "person is owner of land";
    }

    function buyLand(uint8 landId, address seller, address newOwner) public {
        require(LandOwnerMapping[landId] == seller);
        
        LandOwnerMapping[landId] = newOwner;
    }

    function getActiveCerificate(uint8 landId, address owner) public view returns (string) {
        // checking land is owned by the owner
        if(LandOwnerMapping[landId] != owner){
            return "person don't own the land!!";
        }

        // check for previous active certificates
        if(landOwnerCropMapping[landId][owner].isValid == 1){
            return landOwnerCropMapping[landId][owner].croptype;
        }

        return "owner don't have any previous certificate!!";
    }

    function invalidateCertificate(uint8 landId, address owner) public{
        // checking land is owned by the owner
        require(LandOwnerMapping[landId]==owner);

        // check for previous certificates
        require(landOwnerCropMapping[landId][owner].isValid != 0);

        string storage ct = landOwnerCropMapping[landId][owner].croptype;
        landOwnerCropMapping[landId][owner] = cropSowDetail(0, "inactive", ct, now);
    }

    function newCertificate(uint8 landId, address owner,string _cropType) public {
        // checking land is owned by the owner
        require(LandOwnerMapping[landId] == owner);

        // check that owner don't have any previous active certificates
        require(landOwnerCropMapping[landId][owner].isValid == 0);

        landOwnerCropMapping[landId][owner] = cropSowDetail(1, "active", _cropType, now);        
    }

    function getActiveInsurance(uint8 landId, address owner) public view returns (string) {
        // checking land is owned by the owner
        if(LandOwnerMapping[landId] != owner){
            return "land is not owned by the person!!";
        }

        // check that owner have crop active certificate of the given crop
        if(landOwnerCropMapping[landId][owner].isValid != 1){
            return "owner don't have valid crop sowing certificate!!";
        }

        string storage croptype = landOwnerCropMapping[landId][owner].croptype;

        if(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid == 0){
            return "person don't have valid insurance!!";
        }

        return landOwnerCropInsuranceMapping[landId][owner][croptype].number;    
    }

    function invalidateInsurance(uint8 landId, address owner, string croptype) public {
        // checking land is owned by the owner
        require(LandOwnerMapping[landId] == owner);

        // check that owner have crop active certificate of the given crop
        require(landOwnerCropMapping[landId][owner].isValid == 1 && keccak256(landOwnerCropMapping[landId][owner].croptype) == keccak256(croptype));

        require(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid != 0);
        
        string storage insuranceNumber = landOwnerCropInsuranceMapping[landId][owner][croptype].number;
        
        landOwnerCropInsuranceMapping[landId][owner][croptype] = insuranceDetail(0, insuranceNumber, now);        
    }
    
    function newInsurance(uint8 landId, address owner, string croptype, string insuranceNumber) public {
        // checking land is owned by the owner
        require(LandOwnerMapping[landId] == owner);

        // check that owner have crop active certificate of the given crop
        require(landOwnerCropMapping[landId][owner].isValid == 1 && keccak256(landOwnerCropMapping[landId][owner].croptype) == keccak256(croptype));

        require(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid == 0);

        landOwnerCropInsuranceMapping[landId][owner][croptype] = insuranceDetail(1, insuranceNumber, now);        
    }


    function getClaimDetails(uint8 landId, address owner, string croptype) public view returns (string) {
        // checking land is owned by the owner
        if(LandOwnerMapping[landId] != owner){
            return "land not owned by the person!!";
        }

        // check that owner have crop active certificate of the given crop
        if(landOwnerCropMapping[landId][owner].isValid != 1 || keccak256(landOwnerCropMapping[landId][owner].croptype) != keccak256(croptype)){
            return "error in crop sowing certificate!!";
        }

        // check that user has valid insurance to claim
        if(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid != 1){
            "person don't have a valid insurance";
        }

        string storage insuranceNumber = landOwnerCropInsuranceMapping[landId][owner][croptype].number;

        return landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber].status;
    }

    function claimInsurance(uint8 landId, address owner, string croptype) public {
        // checking land is owned by the owner
        require(LandOwnerMapping[landId] == owner);

        // check that owner have crop active certificate of the given crop
        require(landOwnerCropMapping[landId][owner].isValid == 1 && keccak256(landOwnerCropMapping[landId][owner].croptype) == keccak256(croptype));

        // check that user has valid insurance to claim
        require(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid == 1);

        string storage insuranceNumber = landOwnerCropInsuranceMapping[landId][owner][croptype].number;

        // check that user have not already claimed the insurance
        require(landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber].isValid == 0);

        landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber] = claimDetail(1, "pending", now);        
    }

    function passRejectClaim(uint8 landId, address owner, string croptype, string st) public {
        // checking land is owned by the owner
        require(LandOwnerMapping[landId] == owner);

        // check that owner have crop active certificate of the given crop
        require(landOwnerCropMapping[landId][owner].isValid == 1 && keccak256(landOwnerCropMapping[landId][owner].croptype) == keccak256(croptype));

        // check that user has valid insurance to claim
        require(landOwnerCropInsuranceMapping[landId][owner][croptype].isValid == 1);

        string storage insuranceNumber = landOwnerCropInsuranceMapping[landId][owner][croptype].number;

        // check that user have not already claimed the insurance
        require(landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber].isValid == 1);
        require(keccak256(landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber].status) == keccak256("pending"));

        landOwnerInsuranceClaimMapping[landId][owner][insuranceNumber] = claimDetail(0, st, now);        
    }
}