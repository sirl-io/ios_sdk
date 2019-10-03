//
//  SirlUser.swift
//  pipsSDKDev
//
//  Created by Wei Cai on 5/11/18.
//  Copyright © 2018 SIRL Inc.. All rights reserved.
//

import Foundation
import os.log
#if canImport(SIRLCore)
import SIRLCore
#endif

@available(iOS 10.0, *)
public class SirlUser {
    private var user: User?
    private let apiClient = SirlAPIClient.shared
    private let cache = CacheManager.shared
    private let mLog = OSLog(subsystem: "com.sirl.user", category: "Network")

    public var isLoggedIn: Bool {return _isLoggedIn}
    public var accessToken: String? {return user?.id}
    public var userId: String? {return user?.userId}
    public var sessionToken: SirlSessionToken?
    public var userMeta: SirlUserMeta?
    public weak var delegate: SirlUserDelegate?

    public static let shared = SirlUser()

    init() {
        _ = restoreUser()
    }

    private var _isLoggedIn: Bool = false {
        didSet {
            self.delegate?.didChangeLoginStatus?(status: isLoggedIn)
        }
    }

    public func restoreUser() -> Bool {
        cache.retrive(SIRL_USER_CACHE_KEY) { (user: User?) in
            if let mUser = user {
                if let createDate = mUser.created, let ttl = mUser.ttl {
                    let now = Date()
                    let expirarionDate = createDate.addingTimeInterval(TimeInterval(ttl))
                    if now > expirarionDate {
                        self.cache.remove(SIRL_USER_CACHE_KEY, completion: {
                            self._isLoggedIn = false
                            os_log("User cache expired", log: self.mLog, type: .error)
                        })
                    } else {
                        self.user = mUser
                        self._isLoggedIn = true
                        os_log("User restored", log: self.mLog, type: .error)
                    }
                } else {
                    self.user = mUser
                    self._isLoggedIn = true
                    os_log("User restored", log: self.mLog, type: .error)
                }
            } else {
                self._isLoggedIn = false
                os_log("No valid user cache", log: self.mLog, type: .error)
            }
        }
        return _isLoggedIn
    }

    internal func cacheUser() {
        if !_isLoggedIn || user == nil {
            return
        }
        cache.store(key: SIRL_USER_CACHE_KEY, object: user!, memCaheOnly: false) {
            os_log("Sirl User Info Cached", log: self.mLog, type: .debug)
        }
    }

    public func login(login: String, password: String, completion: ((Result<User>) -> Void)? = nil ) -> Bool {
        if _isLoggedIn {return isLoggedIn}
        let userInfo = UserCredentials(login: login, password: password)
        apiClient.send(UserLogin(userCredentials: userInfo)) { (res) in
            switch res {
            case .success(let result):
                self._isLoggedIn = true
                self.user = result
                os_log("Sirl Login Succeed", log: self.mLog, type: .debug)
                self.cacheUser()
                self.getUserMeta()
                completion?(.success(result))
            case .failure(let error):
                os_log("Login error: %@", log: self.mLog, type: .error, error.localizedDescription)
                completion?(.failure(error))
            }
        }
        return self._isLoggedIn
    }

    public func getUserMeta(success: ((SirlUserMeta) -> Void)? = nil) {
        if let token = self.accessToken {
            cache.retrive(SIRL_USER_META_CACHE_KEY + token) { (info: SirlUserMeta?) in
                if let usrInfo = info {
                    self.userMeta = usrInfo
                    success?(usrInfo)
                    return
                }
            }
            self.apiClient.send(GetUserInfo(),
                                withAccessToken: token,
                                completion: { (res ) in
                                    switch res {
                                    case .success(let info):
                                        self.userMeta = info
                                        self.cache.store(key: SIRL_USER_META_CACHE_KEY+token, object: info, memCaheOnly: false) {
                                            os_log("Sirl Meta Info Cached", log: self.mLog, type: .debug)
                                        }
                                        success?(info)
                                    case .failure(let err):
                                        os_log("Error geting user info: %@", log: self.mLog, type: .error, err.localizedDescription)
                                    }

            })
        }
    }

    public func logout(completion:(() -> Void)? = nil) {
        self.cache.remove(SIRL_USER_CACHE_KEY, completion: nil)
        if let token = self.accessToken {
            self.cache.remove(SIRL_USER_CACHE_KEY+token, completion: nil)
        }
        self.userMeta = nil
        self.user = nil
        self._isLoggedIn = false
        completion?()
    }

    public func requestFirebaseToken(fcmToken: String?, completion: ((String?, Error?) -> Void)? = nil) {
        if _isLoggedIn {
            if self.accessToken != nil {
                if fcmToken == nil {
                    self.logout()
                    return
                }
                apiClient.send(GetFirebaseToken(fcmToken: FirebaseDeviceToken(fcmToken: fcmToken!)),
                               withAccessToken: accessToken!) { (res) in
                                switch res {
                                case .success(let result):
                                    os_log("Firebase token received", log: self.mLog, type: .debug)
                                    completion?(result.token, nil)
                                    completion?(result.token, nil)
                                case .failure(let error):
                                    self.logout()
                                    os_log("Firebase token error: %@", log: self.mLog, type: .error, error.localizedDescription)
                                    completion?(nil, error)

                                }
                }
            } else {
                let error = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "Invaild access token"])
                completion?(nil, error)
            }
        } else {
            let error = NSError(domain: "", code: 401, userInfo: [ NSLocalizedDescriptionKey: "User has not yet loged in"])
            completion?(nil, error)
        }
    }

    public func getSessionToken(mlId: Int32, pipsLibVer: String, appVer: String, completion: ((SirlSessionToken?, Error?) -> Void)? = nil) {
        let apiClient = SirlAPIClient.shared
        let mLog = OSLog(subsystem: "com.sirl.user", category: "Network")
        apiClient.send(GetSessionToken(mlId: mlId, pipsLibVer: pipsLibVer, appVer: appVer)) { (res) in
            switch res {
            case .failure(let error):
                completion?(nil, error)
                os_log("Failed getting Access Token: %@", log: mLog, type: .error, error.localizedDescription)
            case .success(let token):
                os_log("The Session Token is : %@", log: mLog, type: .debug, token.token)
                self.sessionToken = token
                completion?(token, nil)
            }
        }
    }

    public func resetPassword(login: String, completion: ((Error?) -> Void)? = nil) {
        let apiClient = SirlAPIClient.shared
        apiClient.send(UserReset(login: login)) { (res) in
            switch(res) {
            case .failure(let err):
                completion?(err)
            case .success:
                completion?(nil)
            }
        }

    }

}
