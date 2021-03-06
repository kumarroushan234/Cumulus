/*
    Copyright (c) 2017 Salesforce.org
    All rights reserved.
    
    Redistribution and use in source and binary forms, with or without
    modification, are permitted provided that the following conditions are met:
    
    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.
    * Redistributions in binary form must reproduce the above copyright
      notice, this list of conditions and the following disclaimer in the
      documentation and/or other materials provided with the distribution.
    * Neither the name of Salesforce.org nor the names of
      its contributors may be used to endorse or promote products derived
      from this software without specific prior written permission.
 
    THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
    "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT 
    LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS 
    FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE 
    COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, 
    INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, 
    BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; 
    LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER 
    CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT 
    LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN 
    ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE 
    POSSIBILITY OF SUCH DAMAGE.
*/
/**
* @author Salesforce.org
* @date 2017
* @group Utilities
* @description Unit tests for UTIL_Query class
*/
@isTest
private class UTIL_Query_TEST {
	
    /*********************************************************************************************************
    @description 
        Tests SOQL builder when duplicate fields are added to SELECT fields
    verify:
        The SOQL contains unique field names 
    **********************************************************************************************************/   
    private static testMethod void testSoqlDoesNotContainDuplicateSelectFields() {
        String[] selectFields = new String[] {
            'Id', 'accountId', 'ACCOUNTid',
            'npo02__Household__r.Number_of_HOUSEHOLD_Members__c',
            'npo02__Household__r.NUMBER_of_Household_MEMBERS__C',
            'firstname', 'FirstName', 'FIRSTNAME', 'FIRSTname'
        };

        String soql = new UTIL_Query()
            .withSelectFields(selectFields)
            .withFrom('Contact')
            .build();
        
        String expectedSoql = 'SELECT Id, accountId, npo02__Household__r.Number_of_HOUSEHOLD_Members__c, firstname FROM Contact';

        System.assertEquals(expectedSoql, soql, 'SOQL should exclude duplicate field names');
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when WHERE Clause is not provided
    verify:
        The SOQL contains SELECT fields and a FROM value
    **********************************************************************************************************/   
    private static testMethod void testSoqlIsCorrectWhenWhereClauseIsNotProvided() {
        String[] selectFields = new String[] { 'Id', 'Name' };

        String soql = new UTIL_Query()
            .withSelectFields(selectFields)
            .withFrom('Account')
            .build();
        
        String expectedSoql = 'SELECT Id, Name FROM Account';

        System.assertEquals(expectedSoql, soql, 'SOQL should be correct without WHERE clause');
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when WHERE Clause is provided
    verify:
        The SOQL contains WHERE Clause
    **********************************************************************************************************/   
    private static testMethod void testSoqlIsCorrectWhenWhereClauseIsProvided() {
        Account[] accounts = new Account[] { 
            new Account(Name = 'Test1'),
            new Account(Name = 'Test2'),
            new Account(Name = 'Test3')
        };
        insert accounts;

        Account[] expectedAccounts = new Account[] { accounts[0], accounts[1] };

        String[] selectFields = new String[] { 'Id', 'Name' };

        String soql = new UTIL_Query()
            .withSelectFields(selectFields)
            .withFrom('Account')
            .withWhere('Id IN :expectedAccounts')
            .build();
        
        String expectedSoql = 'SELECT Id, Name FROM Account WHERE Id IN :expectedAccounts';

        System.assertEquals(expectedSoql, soql, 'SOQL should include WHERE clause');

        Account[] actualAccounts = Database.query(soql);

        Set<Id> expectedAccountIds = new Map<Id, Account>(expectedAccounts).keySet();
        Set<Id> actualAccountIds = new Map<Id, Account>(actualAccounts).keySet();

        System.assertEquals(expectedAccountIds.size(), actualAccountIds.size(), 'Expected Accounts ' + expectedAccounts + ' should be the same as actual Accounts ' + actualAccounts);
        System.assert(expectedAccountIds.containsAll(actualAccountIds), 'Expected Accounts ' + expectedAccounts + ' should be the same as actual Accounts ' + actualAccounts);
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when SELECT fields are not provided
    verify:
        The build() throws an exception
    **********************************************************************************************************/   
    private static testMethod void testSoqlBuildFailsWhenNoSelectFieldIsProvided() {
        try {
            String soql = new UTIL_Query()
                .withFrom('Account')
                .build();

            System.assert(false, 'An exception should be thrown when SOQL has no select field');
        } catch (Exception e) {
            System.assertEquals('At least one SELECT field is required.', e.getMessage());
        }
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when a SELECT field is empty or null
    verify:
        The build() throws an exception
    **********************************************************************************************************/   
    private static testMethod void testSoqlBuildFailsWhenSelectFieldIsEmpty() {
        for (String fieldName : new String[] { ' ', '', null}) {
            try {
                String soql = new UTIL_Query()
                    .withSelectFields(new String[] { fieldName })
                    .withFrom('Account')
                    .build();

                System.assert(false, 'An exception should be thrown when SELECT field is empty or null');
            } catch (Exception e) {
                System.assertEquals('SELECT field cannot be empty or null.', e.getMessage());
            }
        }
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when FROM entity value is not provided
    verify:
        The build() throws an exception
    **********************************************************************************************************/   
    private static testMethod void testSoqlBuildFailsWhenFromValueIsNotProvided() {
        String[] selectFields = new String[] { 'Id', 'Name' };

        try {
            String soql = new UTIL_Query()
                .withSelectFields(selectFields)
                .build();

            System.assert(false, 'An exception should be thrown when SOQL has no FROM value');
        } catch (Exception e) {
            System.assertEquals('The FROM value is required.', e.getMessage());
        }
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when a WHERE clause is empty or null
    verify:
        The build() throws an exception
    **********************************************************************************************************/   
    private static testMethod void testSoqlBuildFailsWhenWhereClauseIsEmpty() {
        String[] selectFields = new String[] { 'Id', 'Name' };

        for (String whereClause : new String[] { ' ', '', null}) {
            try {
                String soql = new UTIL_Query()
                    .withSelectFields(selectFields)
                    .withFrom('Account')
                    .withWhere('Id IN :accounts')
                    .withWhere(whereClause)
                    .build();

                System.assert(false, 'An exception should be thrown when WHERE clause is empty or null');
            } catch (Exception e) {
                System.assertEquals('WHERE clause cannot be empty or null.', e.getMessage());
            }
        }
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when toLabelSalutation is ON
    verify:
        The SOQL contains toLabel() for the Salutation field 
    **********************************************************************************************************/   
    private static testMethod void testSoqlIncludesToLabelSalutationWhenSettingsIsOn() {
        String[] selectFields = new String[] {
            'Id', 'AccountId', 'SaLuTaTiOn', 'FirstName', 'LastName'
        };

        String soql = new UTIL_Query()
            .withSelectFields(selectFields)
            .withToLabelSalutation()
            .withFrom('Contact')
            .build();
    
        String expectedSoql = 'SELECT Id, AccountId, toLabel(SaLuTaTiOn), FirstName, LastName FROM Contact';

        System.assertEquals(expectedSoql, soql, 'SOQL should include toLabel for Salutation field');
    }

    /*********************************************************************************************************
    @description 
        Tests SOQL builder when toLabelSalutation is OFF
    verify:
        The SOQL contains Salutation field without toLabel()
    **********************************************************************************************************/   
    private static testMethod void testSoqlExcludesToLabelSalutationWhenSettingsIsOff() {
        String[] selectFields = new String[] {
            'Id', 'AccountId', 'SaLuTaTiOn', 'FirstName', 'LastName'
        };

        String soql = new UTIL_Query()
            .withSelectFields(selectFields)
            .withFrom('Contact')
            .build();
    
        String expectedSoql = 'SELECT Id, AccountId, SaLuTaTiOn, FirstName, LastName FROM Contact';

        System.assertEquals(expectedSoql, soql, 'SOQL should not include toLabel for Salutation field');
    }
	
}