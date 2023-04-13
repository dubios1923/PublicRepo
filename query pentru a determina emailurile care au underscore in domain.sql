/****** Script for SelectTopNRows command from SSMS  ******/
SELECT  [Client Number]
      ,[Email]
      ,[Residence Type]
      ,[Street Type]
      ,[Street Name]
      ,[Street Number]
      ,[Building]
      ,[Entrance]
      ,[App no]
      ,[County]
      ,[Locality]
      ,[Postal Code]
      ,[Supplementary Address Details]
      ,[Country Id]
      ,[Phone Home]
      ,[Phone Office]
      ,[Phone Mobile]
      ,[Fax]
      ,[ClientEntityID]
      ,[Access right]
      ,[Portability right]
      ,[Opposition right]
      ,[Rectification right]
      ,[Restriction right]
      ,[Right to be forgotten]
  FROM [insDataWarehouse].[dbo].[cif_ClientDatalife]
  where CHARINDEX('_', SUBSTRING(email, CHARINDEX('@', email)+1, LEN(email))) > 0;