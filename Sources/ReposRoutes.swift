//
//  ReposRoutes.swift
//  Pods
//
//  Created by yansong li on 2016-02-21.
//
//

import Foundation

public class ReposRoutes {
    public unowned let client: GithubNetWorkClient
    init(client: GithubNetWorkClient) {
        self.client = client
    }
    
    /**
     Get current authenticated user's repo.
     
     - returns: an RpcRequest, whose response result contains `[GithubRepo]`.
     */
    public func getAuthenticatedUserRepos() -> RpcRequest<RepoArraySerializer, StringSerializer> {
        return RpcRequest(client: self.client, host: "api", route: "/user/repos", method: .GET, responseSerializer: RepoArraySerializer(), errorSerializer: StringSerializer())
    }
    
    /**
     Get a specific repo with repo name and repo owner name
     
     - parameter name:  this repo's name
     - parameter owner: repo's owner name
     
     - returns: an RpcRequest, whose response result contain `GithubRepo`.
     */
    public func getRepo(name: String, owner: String) -> RpcRequest<RepoSerializer, StringSerializer> {
        if name.characters.count == 0 || owner.characters.count == 0 {
            print(Constants.ErrorInfo.InvalidInput.rawValue)
        }
        
        return RpcRequest(client: self.client,
            host: "api",
            route: "/repos/\(owner)/\(name)",
            method: .GET,
            responseSerializer: RepoSerializer(),
            errorSerializer: StringSerializer())
    }
    
    /**
     List public repositories for the specified user.
     
     - parameter owner: user name
     - parameter page: when user has a lot of repos, pagination will be applied.
     
     - returns: an RpcRequest, whose response result contains `[GithubRepo]`, if pagination is applicable, response result contains `nextpage`.
     
     - note: Note that page numbering is 1-based and that omitting the ?page parameter will return the first page.
     */
    public func getRepoFrom(owner owner: String, page: String = "1") -> RpcCustomResponseRequest<RepoArraySerializer, StringSerializer, String> {
        if owner.characters.count == 0 {
            print(Constants.ErrorInfo.InvalidInput.rawValue)
        }
        
        let httpResponseHandler:(NSHTTPURLResponse?)->String? = { (response: NSHTTPURLResponse?) in
            if let nonNilResponse = response,
                link = (nonNilResponse.allHeaderFields["Link"] as? String),
                sinceRange = link.rangeOfString("page=") {
                    var retVal = ""
                    var checkIndex = sinceRange.endIndex
                    
                    while checkIndex != link.endIndex {
                        let character = link.characters[checkIndex]
                        let characterInt = character.zeroCharacterBasedunicodeScalarCodePoint()
                        if characterInt>=0 && characterInt<=9 {
                            retVal += String(character)
                        } else {
                            break
                        }
                        checkIndex = checkIndex.successor()
                    }
                    return retVal
            }
            return nil
        }
        
        return RpcCustomResponseRequest(client: self.client,
            host: "api",
            route: "/users/\(owner)/repos",
            method: .GET,
            params: ["page":page],
            postParams: nil,
            postData: nil,
            customResponseHandler:httpResponseHandler,
            responseSerializer: RepoArraySerializer(),
            errorSerializer: StringSerializer())
    }
    
    /**
     Use API URL to get the full information of Repo
     
     - parameter url: api URL
     
     - returns: Request Object you could get the full information from its successful serializer.
     */
    public func getAPIRepo(url url: String) -> DirectAPIRequest<RepoSerializer, StringSerializer> {
        if url.characters.count == 0 {
            print(Constants.ErrorInfo.InvalidInput.rawValue)
        }
        
        return DirectAPIRequest(client: self.client,
            apiURL: url,
            method: .GET,
            responseSerializer: RepoSerializer(),
            errorSerializer: StringSerializer())
    }
}
