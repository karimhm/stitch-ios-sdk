import StitchCoreSDK

/**
  A protocol to be inherited by classes that need to take action whenever a particular `StitchAppClient` performs an
  authentication event. An instance of a `StitchAuthDelegate` must be registered with a `StitchAuth` for this to work
  correctly.

  - Note:
     This protocol uses an extension to provide default implementations. This is for your convenience, so you do not
     have to implement every method here to satisfy the protocol requirements. This however does mean that if you plan
     on subclassing your implementation of `StitchAuthDelegate`, you may run into unexpected issues where the empty
     default implementation is called instead of your subclass implementation. If this does happen in your code, see
     [this article](https://team.goodeggs.com/overriding-swift-protocol-extension-default-implementations-d005a4428bda)
     for more context and potential workarounds, or open an issue in our GitHub repository.

    - Tag: StitchAuthDelegate
 */
public protocol StitchAuthDelegate: class {
    /**
     * A method to be called whenever a `StitchAppClient` performs an authentication event.
     * Note, when this method is invoked by a `StitchAuth` for which this delegate is registered,
     * the invocation will be dispatched to a non-main dispatch queue, so be sure to dispatch any
     * UI operations back to the main `DispatchQueue`.
     *
     * - parameters:
     *    - fromAuth: The `StitchAuth` object that caused the authentication event.
     */
    func onAuthEvent(fromAuth: StitchAuth)

    /**
     * Called whenever a user is added to the device for the first time. If this
     * is as part of a login, this method will be called before
     * `onUserLoggedIn`, and `onActiveUserChanged` are called.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the user was added.
     *            It can be used to infer the current state of authentication.
     *    - addedUser: The user that was added to the device.
     */
    func onUserAdded(auth: StitchAuth, addedUser: StitchUser)

    /**
     * Called whenever a user is logged in. This will be called before
     * `onActiveUserChanged` is called.
     *
     * Note: if an anonymous user was already logged in on the device, and you
     * log in with an `AnonymousCredential`, this method will not be called,
     * as the underlying `StitchAuth` will reuse the anonymous user's existing
     * session, and will thus only trigger `onActiveUserChanged`.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the user was logged in.
     *            It can be used to infer the current state of authentication.
     *    - loggedInUser: The user that was logged in.
     */
    func onUserLoggedIn(auth: StitchAuth, loggedInUser: StitchUser)

    /**
     * Called whenever a user is linked to a new identity.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the user was linked.
     *            It can be used to infer the current state of authentication.
     *    - linkedUser: The user that was linked to a new identity.
     */
    func onUserLinked(auth: StitchAuth, linkedUser: StitchUser)

    /**
     * Called whenever a user is logged out. The user logged out is not
     * necessarily the active user. If the user logged out was the active user,
     * then `onActiveUserChanged` will be called after this method. If the user
     * was an anonymous user, that user will also be removed and
     * `onUserRemoved` will also be called.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the user was logged out.
     *            It can be used to infer the current state of authentication.
     *    - loggedOutUser: The user that was logged out.
     */
    func onUserLoggedOut(auth: StitchAuth, loggedOutUser: StitchUser)

    /**
     * Called whenever the active user changes. This may be due to a call to
     * `StitchAuth.loginWithCredential`, `StitchAuth.switchToUserWithId`,
     * `StitchAuth.logout`, `StitchAuth.logoutUserWithId`,
     * `StitchAuth.removeUser`, or `StitchAuth.removeUserWithId`.
     * This may also occur on a normal request if a user's session is invalidated
     * and they are forced to log out.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the the active user changed.
     *            It can be used to infer the current state of authentication.
     *    - currentActiveUser: The active user after the change.
     *    - previousActiveUser: The active user before the change.
     */
    func onActiveUserChanged(auth: StitchAuth,
                             currentActiveUser: StitchUser?,
                             previousActiveUser: StitchUser?)

    /**
     * Called whenever a user is removed from the list of users on the device.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the the user was removed.
     *            It can be used to infer the current state of authentication.
     *    - removedUser: The user that was removed.
     */
    func onUserRemoved(auth: StitchAuth, removedUser: StitchUser)

    /**
     * Called whenever this delegate is registered for the first time. This can
     * be useful to infer the state of authentication, because any events that
     * occurred before the delegate was registered will not be seen by the
     * delegate.
     *
     * - parameters:
     *    - auth: The instance of `StitchAuth` where the the delegate was registered.
     *            It can be used to infer the current state of authentication.
     */
    func onDelegateRegistered(auth: StitchAuth)
}

// extensions that provide default implementations of the the auth delegate methods
public extension StitchAuthDelegate {
    public func onDelegateRegistered(auth: StitchAuth) { }

    public func onAuthEvent(fromAuth: StitchAuth) { }

    public func onUserAdded(auth: StitchAuth, addedUser: StitchUser) { }

    public func onUserLoggedIn(auth: StitchAuth, loggedInUser: StitchUser) { }

    public func onUserLinked(auth: StitchAuth, linkedUser: StitchUser) { }

    public func onUserLoggedOut(auth: StitchAuth, loggedOutUser: StitchUser) { }

    public func onActiveUserChanged(auth: StitchAuth,
                                    currentActiveUser: StitchUser?,
                                    previousActiveUser: StitchUser?) { }

    public func onUserRemoved(auth: StitchAuth, removedUser: StitchUser) { }
}

// wrapper holding a weak reference to a StitchAuthDelegate
class AnyStitchAuthDelegate: StitchAuthDelegate {
    weak var reference: StitchAuthDelegate?

    init(_ reference: StitchAuthDelegate) {
        self.reference = reference
    }

    func onAuthEvent(fromAuth: StitchAuth) {
        reference?.onAuthEvent(fromAuth: fromAuth)
    }

    func onUserAdded(auth: StitchAuth, addedUser: StitchUser) {
        reference?.onUserAdded(auth: auth, addedUser: addedUser)
    }

    func onUserLoggedIn(auth: StitchAuth, loggedInUser: StitchUser) {
        reference?.onUserLoggedIn(auth: auth, loggedInUser: loggedInUser)
    }

    func onUserLinked(auth: StitchAuth, linkedUser: StitchUser) {
        reference?.onUserLinked(auth: auth, linkedUser: linkedUser)
    }

    func onUserLoggedOut(auth: StitchAuth, loggedOutUser: StitchUser) {
        reference?.onUserLoggedOut(auth: auth, loggedOutUser: loggedOutUser)
    }

    func onActiveUserChanged(auth: StitchAuth, currentActiveUser: StitchUser?, previousActiveUser: StitchUser?) {
        reference?.onActiveUserChanged(auth: auth,
                                       currentActiveUser: currentActiveUser,
                                       previousActiveUser: previousActiveUser)
    }

    func onUserRemoved(auth: StitchAuth, removedUser: StitchUser) {
        reference?.onUserRemoved(auth: auth, removedUser: removedUser)
    }

    func onDelegateRegistered(auth: StitchAuth) {
        reference?.onDelegateRegistered(auth: auth)
    }
}
