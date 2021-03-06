// swiftlint:disable force_try
import MongoSwift
import StitchCore
import StitchCoreSDK
import StitchCoreAdminClient
import StitchDarwinCoreTestUtils
@testable import StitchCoreRemoteMongoDBService
import StitchCoreLocalMongoDBService
@testable import StitchRemoteMongoDBService

class LocalPerformanceTestContext: SyncPerformanceTestContext {
    let dbName: String
    let collName: String
    let userId: String
    let client: StitchAppClient
    let mongoClient: RemoteMongoClient
    let coll: RemoteMongoCollection<Document>
    let testParams: TestParams
    let harness: SyncPerformanceIntTestHarness

    let joiner = ThrowingCallbackJoiner()
    let streamJoiner = StreamJoiner()

    required init(harness: SyncPerformanceIntTestHarness,
                  testParams: TestParams) throws {
        self.harness = harness
        self.testParams = testParams

        dbName = ObjectId().oid
        collName = ObjectId().oid

        harness.setUp()

        let app = try! harness.createApp()
        _ = try! harness.addProvider(toApp: app.1, withConfig: ProviderConfigs.anon())
        let svc = try! harness.addService(toApp: app.1, withType: "mongodb", withName: "mongodb1",
                                          withConfig: ServiceConfigs.mongodb(name: "mongodb1",
                                                                             uri: harness.mongodbUri))
        let rule = RuleCreator.mongoDb(database: dbName, collection: collName,
                                       roles: [RuleCreator.Role(read: true, write: true)],
                                       schema: RuleCreator.Schema())
        _ = try! harness.addRule(toService: svc.1, withConfig: rule)

        client = try! harness.appClient(forApp: app.0, withTransport: harness.networkTransport)
        client.auth.login(withCredential: AnonymousCredential(), joiner.capture())
        let _: Any? = try joiner.value()
        userId = client.auth.currentUser?.id ?? ""

        mongoClient = try! client.serviceClient(fromFactory: remoteMongoClientFactory, withName: "mongodb1")
        coll = mongoClient.db(dbName).collection(collName)

        try clearLocalDB()

        coll.sync.proxy.dataSynchronizer.isSyncThreadEnabled = false
        coll.sync.proxy.dataSynchronizer.stop() // Failing here occaisonally
    }

    func tearDown() throws {
        if coll.sync.proxy.dataSynchronizer.instanceChangeStreamDelegate != nil {
            coll.sync.proxy.dataSynchronizer.instanceChangeStreamDelegate.stop()
        }

        try clearLocalDB()
    }
}
